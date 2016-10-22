require 'grimoire'

module Grimoire
  # Dependency representation
  class Dependency

    # @return [String] name of dependency
    attr_reader :name
    # @return [Requirement] requirement of dependency
    attr_reader :requirement
    # @return [Symbol] type of dependency
    attr_reader :type
    # @return [TrueClass, FalseClass] dependency is a prerelease
    attr_accessor :prerelease

    # Create a new Dependency instance
    #
    # @param name [String] name of dependency
    # @param requirements [Object] requirement of dependency
    # @return [self]
    def initialize(name, *requirements)
      @name = name.to_s.freeze
      @prerelease = false
      @type = requirements.last.is_a?(Symbol) ? requirements.pop : :runtime
      requirements = requirements.first if requirements.size == 1
      @requirement = requirements.is_a?(REQUIREMENT_CLASS) ? requirements :
        REQUIREMENT_CLASS.new(requirements)
    end

    # @return [String] inspection of instance
    def inspect
      "<#{self.class} @name=#{name} @type=#{type} @prerelease=" \
        "#{prerelease.inspect} requirements=#{requirement.inspect}>"
    end

    # @return [TrueClass, FalseClass] instance is prerelease
    def prerelease?
      !!(prerelease || requirement.prerelease?)
    end

    # Compare equivalency of dependencies
    #
    # @param rhv [Dependency]
    # @return [TrueClass, FalseClass]
    def ==(rhv)
      rhv.is_a?(self.class) &&
        rhv.name == name &&
        rhv.type == type &&
        rhv.requirement == requirement
    end

    # Compare against other Dependency
    #
    # @param rhv [Dependency]
    # @return [Integer]
    def <=>(rhv)
      name <=> rhv.name
    end

    # Merge dependency with another dependency
    #
    # @param rhv [Dependency]
    # @return [Dependency]
    def merge(rhv)
      if(name != rhv.name)
        raise ArgumentError.new("#{self} and #{rhv} have different names")
      end
      new_requirements = requirement.requirements + rhv.requirement.requirements
      new_requirements.uniq!
      self.class.new(name, new_requirements)
    end

    # @return [Integer]
    def hash
      name.hash ^ type.hash ^ requirement.hash
    end
  end
end
