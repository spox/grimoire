require 'grimoire'

module Grimoire
  # Requirement solver
  class Solver < Utility

    # Ceiling for number of loops allowed during path generation
    MAX_GENERATION_LOOPS = 100000

    include Bogo::Memoization

    attribute :requirements, RequirementList, :required => true
    attribute :system, System, :required => true
    attribute :score_keeper, UnitScoreKeeper

    # @return [System] subset of full system based on requirements
    attr_reader :world

    def initialize(*_)
      super
      @world = System.new
      build_world(requirements.requirements, world, system)
      world.scrub!
    end

    # Build the world required for the solver (the subset of the
    # entire system required by the requirements)
    #
    # @param deps [DEPENDENCY_CLASS] dependencies required to resolve
    # @param my_world [System] system to populate with units
    # @param root [System] superset system to extract units
    def build_world(deps=nil, my_world=nil, root = nil)
      deps = requirement.requirements unless deps
      my_world = world unless my_world
      root = system unless root
      deps.each do |dep|
        units = root.subset(dep.name, dep.requirement)
        units.each do |unit|
          build_world(unit.dependencies, my_world, root)
        end
        my_world.add_unit(units)
      end
    end

    # @return [Smash<{Unit#name:Bogo::PriorityQueue}>]
    def queues
      memoize(:queues) do
        Smash[
          world.units.map do |name, items|
            queue = Bogo::PriorityQueue.new
            populate_queue(queue, items)
            [name, queue]
          end
        ]
      end
    end

    # Populate queue with units
    #
    # @param p_queue [Bogo::PriorityQueue]
    # @param units [Array<Unit>]
    # @return [Bogo::PriorityQueue]
    def populate_queue(p_queue, units)
      i = 0
      units = units.map do |unit|
        [unit, score_unit(unit, i += 1)]
      end
      p_queue.multi_push(units)
      p_queue
    end

    # Provide score for given unit
    #
    # @param unit [Unit]
    # @param score [Integer] current score
    # @return [Numeric] score
    def score_unit(unit, score)
      if(score_keeper)
        score_keeper.score_for(unit) || score
      else
        score
      end
    end

    # Repopulate the given queue
    #
    # @param name [String]
    # @return [self]
    def reset_queue(name)
      queue = populate_queue(
        Bogo::PriorityQueue.new,
        world.units[name]
      )
      queues[name] = queue
      self
    end

    # Provide Unit acceptable for given dependency
    #
    # @param dep [DEPENDENCY_CLASS]
    # @return [Unit]
    # @raises [Error::UnitUnavailable]
    def unit_for(dep)
      unit = nil
      until(unit || queues[dep.name].empty?)
        unit = queues[dep.name].pop
        unit = nil unless dep.requirement.satisfied_by?(unit.version)
      end
      unless(unit)
        error = Error::UnitUnavailable.new("Failed to locate valid unit for: #{dep.inspect}")
        error.unit_name = dep.name
        raise error
      end
      unit
    end

    # Resolve path for a given dependency
    #
    # @param dep [DEPENDENCY_CLASS]
    # @param given [DEPENDENCY_CLASS]
    # @return [Array<Unit>]
    def resolve(dep, given=nil)
      unit = given || unit_for(dep)
      if(unit.dependencies.empty?)
        [unit]
      else
        deps = [unit]
        begin
          unit.dependencies.map do |u_dep|
            existing = deps.detect{|d| d.name == u_dep.name}
            if(existing)
              if(u_dep.requirement.satisfied_by?(existing.version))
                next
              else
                deps.delete(existing)
                reset_queue(u_dep.name) unless given
              end
            else
              reset_queue(u_dep.name) unless given
            end
            deps += resolve(u_dep)
            deps.compact!
            u_dep
          end.compact.map do |u_dep|  # validator
            existing = deps.detect{|d| d.name == u_dep.name}
            if(existing)
              unless(u_dep.requirement.satisfied_by?(existing.version))
                deps.delete(existing)
                reset_queue(u_dep.name)
                raise Error::ResolutionPathInvalid.new("Unit <#{existing.inspect}> does not satisfy <#{u_dep.inspect}>")
              end
            end
          end
        rescue Error::ResolutionPathInvalid
          retry
        end
        deps
      end
    end

    # Generate valid constraint paths
    #
    # @return [Bogo::PriorityQueue<Path>]
    def generate!
      custom_unit = Unit.new(
        :name => '~_SOLVER_UNIT_~',
        :version => '1.0.0',
        :dependencies => requirements.requirements
      )
      count = 0
      results = Bogo::PriorityQueue.new
      begin
        until(count > MAX_GENERATION_LOOPS)
          result = resolve(nil, custom_unit)
          results.push(Path.new(:units => result.slice(1, result.size)), count)
          count += 1
        end
      rescue Error::UnitUnavailable
        count = nil
      end
      unless(count.nil?)
        raise Error::MaximumGenerationLoopsExceeded.new("Exceeded maximum allowed loops for path generation: #{MAX_GENERATION_LOOPS}")
      else
        if(results.empty?)
          raise Error::NoSolution.new("Failed to generate valid path for requirements: `#{custom_unit.dependencies.inspect}`")
        else
          results
        end
      end
    end

  end
end
