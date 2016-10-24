require 'grimoire'

module Grimoire
  # Requirement representation
  class Requirement

    # @return [Array<Array(String, Version)>] list of constraints
    attr_reader :requirements

    # Default requirement
    DEFAULT_REQUIREMENT = ['>=', VERSION_CLASS.new(0)]
    # Valid opreators and handling logic
    OPERATORS = {
      '=' => lambda{|l, r| l == r},
      '!=' => lambda{|l, r| l != r},
      '>' => lambda{|l, r| l > r},
      '<' => lambda{|l, r| l < r},
      '>=' => lambda{|l, r| l >= r},
      '<=' => lambda{|l, r| l <= r},
      '~>' => lambda{|l, r| l >= r && l.release < r.bump}
    }
    # Valid pattern for matching constraint string
    OPERATORS_PATTERN = OPERATORS.keys.sort_by(&:size).reverse.map do |op_text|
      Regexp.escape(op_text)
    end.join('|')

    # Parse a requirement and generate a new instance
    #
    # @param req [Version, String, Array]
    # @return [Requirement]
    def self.parse(req)
      if(req.is_a?(VERSION_CLASS))
        ['=', req]
      elsif(req.nil?)
        DEFAULT_REQUIREMENT
      elsif(req.is_a?(Array))
        [
          req.first.to_s,
          req.last.is_a?(VERSION_CLASS) ?
            req.last :
            VERSION_CLASS.new(req.last)
        ]
      else
        match = req.to_s.match(
          /(#{OPERATORS_PATTERN})/
        )
        if(match)
          [match.captures.first,
            VERSION_CLASS.new(match.post_match.strip)]
        else
          ['=', VERSION_CLASS.new(req.to_s)]
        end
      end
    end

    # Create a new Requirement instance
    #
    # @param requirements [Version, String, Array] constraint list
    # @return [self]
    def initialize(*requirements)
      reqs = requirements.compact.uniq
      @requirements = []
      if(reqs.empty?)
        @requirements << DEFAULT_REQUIREMENT
      else
        reqs.each do |req|
          if(req.is_a?(Array))
            req.map do |i_req|
              @requirements << self.class.parse(i_req)
            end
          else
            @requirements << self.class.parse(req)
          end
        end
      end
    end

    # Equal to other instance
    #
    # @param rhv [Requirement]
    # @return [TrueClass, FalseClass]
    def eql?(rhv)
      @requirements.all? do |req|
        rhv.requirements.include?(req)
      end
    end

    # @return [TrueClass, FalseClass] requirement is a prerelease
    def prerelease?
      requirements.any? do |req|
        req.last.prerelease?
      end
    end

    # Check if a version satisfies this requirement
    #
    # @param version [Version]
    # @return [TrueClass, FalseClass]
    def satisfied_by?(version)
      unless(version.is_a?(VERSION_CLASS))
        raise ArgumentError.new("#{VERSION_CLASS} is required: #{version.inspect}")
      end
      requirements.all? do |operator, rhv|
        OPERATORS.fetch(operator, '=').call(version, rhv)
      end
    end

    alias :=== :satisfied_by?

    # @return [String] instance inspection
    def inspect
      "<#{self.class} @prerelease=#{prerelease?.inspect} "\
        "@requirements=#{@requirements.to_s}>"
    end

    # Equivalent to other instance
    #
    # @param rhv [Requirement]
    # @return [TrueClass, FalseClass]
    def ==(rhv)
      requirements == rhv.requirements
    end
  end
end
