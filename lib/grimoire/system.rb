require 'grimoire'

module Grimoire
  # Contains all available Units
  class System

    # @return [Smash]
    attr_reader :units

    # Create new system
    #
    # @return [self]
    def initialize(*_)
      @units = Smash.new
    end

    # Register new unit
    #
    # @param unit [Unit]
    # @return [self]
    def add_unit(*unit)
      if(bad_u = unit.flatten.detect{|u| !u.is_a?(Unit)})
        raise TypeError.new "Expecting `Unit` instance but received `#{bad_u.class}`"
      end
      [unit].flatten.compact.each do |u|
        unless(units[u.name])
          units[u.name] = []
        end
        units[u.name].push(u) unless units[u.name].include?(u)
      end
      self
    end

    # Remove registered unit
    #
    # @param unit [Unit]
    # @param deps
    # @return [self]
    def remove_unit(unit)
      unless(unit.is_a?(Unit))
        raise TypeError.new "Expecting `Unit` instance but received `#{unit.class}`"
      end
      if(units[unit.name])
        units[unit.name].delete(unit)
        if(units[unit.name].empty?)
          units.delete(unit.name)
        end
      end
      self
    end

    # Provide all available units that satisfy the constraint
    #
    # @param unit_name [String]
    # @param constraint [REQUIREMENT_CLASS]
    # @return [Array<Unit>]
    def subset(unit_name, constraint)
      unless(constraint.respond_to?(:requirements))
        raise TypeError.new "Expecting `#{REQUIREMENT_CLASS}` but received `#{constraint.class}`"
      end
      unless(units[unit_name])
        Grimoire.debug "Failed to locate any units loaded in system with requested name: `#{unit_name}`"
        []
      else
        units[unit_name].find_all do |unit|
          constraint.satisfied_by?(unit.version)
        end
      end
    end

    # Removes any duplicate units registered
    # and sorts all unit lists
    #
    # @return [self]
    def scrub!
      units.values.map do |items|
        items.sort!{|x,y| y.version <=> x.version}
        items.uniq!
      end
      self
    end

    # @return [String]
    def to_json(*args)
      MultiJson.dump(
        Smash.new(:units => units),
        *args
      )
    end

    # @return [String]
    def inspect
      "<#{self.class}:#{self.object_id}>: " <<
        units.to_a.sort_by(&:first).map do |name, units|
        "#{name}: #{units.map(&:version).sort.map(&:to_s).join(', ')}"
      end.join("\n")
    end

  end
end
