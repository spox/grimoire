require 'digest/sha2'
require 'grimoire'

module Grimoire
  # Requirement solver
  class Solver < Utility

    # Ceiling for number of loops allowed during path generation
    MAX_GENERATION_LOOPS = 100000

    include Bogo::Memoization

    attribute :restrictions, RequirementList, :coerce => lambda{|x|
      RequirementList.new(:name => 'restrictions', :requirements => x) if x.is_a?(Array)
    }
    attribute :requirements, RequirementList, :required => true, :coerce => lambda{|x|
      RequirementList.new(:name => 'requirements', :requirements => x) if x.is_a?(Array)
    }
    attribute :system, System, :required => true
    attribute :score_keeper, UnitScoreKeeper
    attribute :result_limit, Integer, :required => true, :default => 1

    # @return [System] subset of full system based on requirements
    attr_reader :world
    # @return [System, NilClass] new system subset when pruning
    attr_reader :new_world

    def initialize(*_)
      super
      @world = System.new
      @new_world = nil
      @log = []
      if(restrictions)
        apply_restrictions!
      end
      build_world(requirements.requirements, world, system)
      @log.clear
      world.scrub!
    end

    # Restrictions are simply an implicit expansion of the requirements
    # that. When restrictions are provided, it serves to further
    # restrict the valid units available for solutions
    #
    # @return [self]
    def apply_restrictions!
      restrictions.requirements.each do |rst|
        req = requirements.requirements.detect do |r|
          r.name == rst.name
        end
        if(req)
          new_req = req.merge(rst)
          requirements.requirements.delete(req)
          requirements.requirements.push(new_req)
        else
          requirements.requirements.push(rst)
        end
      end
      self
    end

    # After the world has been generated extraneous units will
    # be included as a result of dependency constraints that may
    # be too loose and are not actually required by any resolution
    # that would be requested. This will run a second pass and remove
    # extraneous items not required.
    #
    # @return [self]
    # @note This must be called explicitly and is provided for
    #   resolving an entire system, not a single resolution path
    def prune_world!
      @new_world = System.new
      requirements.requirements.each do |req|
        unless(world.units[req.name])
          debug "No units available matching requirement name `#{req.name}`! (#{req.inspect})"
          exception = Error::UnitUnavailable.new "No units available for requirement `#{req.name}`"
          exception.unit_name = req.name
          raise exception
        end
        world.units[req.name].each do |r_unit|
          begin
            req_list = RequirementList.new(
              :name => :world_pruner,
              :requirements => [[r_unit.name, r_unit.version.version]]
            )
            path = Solver.new(
              :requirements => req_list,
              :system => world,
              :score_keeper => score_keeper
            ).generate!.pop
            new_world.add_unit(*path.units)
          rescue Error::NoSolution => e
            debug "Failed to generate valid path for: #{r_unit.name}-#{r_unit.version}"
          end
        end
      end
      @world = new_world
      @new_world = nil
      self
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
        sha = Digest::SHA256.hexdigest(MultiJson.dump(units))
        if(@log.include?(sha))
          debug "Units checksum already added to world. Skipping. (`#{sha}`)"
          next
        end
        debug "Logging units checksum for world addition. (`#{sha}`)"
        @log.push(sha)
        units.each do |unit|
          build_world(unit.dependencies, my_world, root)
        end
        debug "Units added to world: #{MultiJson.dump(units.map{|u| {u.name => u.version} })}"
        my_world.add_unit(units)
      end
    end

    # @return [Bogo::PriorityQueue]
    def create_queue
      if(score_keeper)
        Bogo::PriorityQueue.new(score_keeper.preferred_score)
      else
        Bogo::PriorityQueue.new
      end
    end

    # @return [Smash<{Unit#name:Bogo::PriorityQueue}>]
    def queues
      memoize(:queues) do
        Smash[
          world.units.map do |name, items|
            queue = create_queue
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
        score_keeper.score_for(unit, score, :solver => self) || score
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
        create_queue,
        world.units.fetch(name, [])
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
      if(queues[dep.name].nil?)
        raise KeyError.new "No valid units for requested name found within system! (`#{dep.name}`)"
      end
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
    # @param current [Array<Unit>] current units within path
    # @return [Array<Unit>]
    def resolve(dep, given=nil, current=[])
      unit = given || unit_for(dep)
      if(unit.dependencies.empty?)
        [unit]
      else
        deps = [unit]
        begin
          unit.dependencies.map do |u_dep|
            existing = (current + deps).detect{|d| d.name == u_dep.name}
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
            deps += resolve(u_dep, nil, current + deps)
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
        rescue Error::ResolutionPathInvalid => e
          debug "Resolution path deadend: #{e} (trying new path)"
          retry
        end
        deps.uniq
      end
    end

    # Generate valid constraint paths
    #
    # @return [Bogo::PriorityQueue<Path>]
    def generate!
      if(requirements.requirements.empty?)
        raise ArgumentError.new 'No cookbook constraints provided within Batali file!'
      end
      custom_unit = Unit.new(
        :name => '~_SOLVER_UNIT_~',
        :version => '1.0.0',
        :dependencies => requirements.requirements
      )
      count = 0
      debug "Solver Unit: #{MultiJson.dump(custom_unit)}"
      debug{ "Solver world context of unit system: #{world.inspect}" }
      results = Bogo::PriorityQueue.new
      begin
        until(count >= result_limit)
          result = resolve(nil, custom_unit)
          results.push(Path.new(:units => result.slice(1, result.size)), count)
          count += 1
        end
      rescue Error::UnitUnavailable => e
        debug "Failed to locate unit: #{e}"
        count = nil
      end
      if(results.empty?)
        raise Error::NoSolution.new("Failed to generate valid path for requirements: `#{custom_unit.dependencies}`")
      else
        results
      end
    end

  end
end
