module Grimoire
  # Version representation
  class Version
    include Comparable

    # @return [Array<String|Integer>] version segments
    attr_reader :segments

    # Create a new instance
    #
    # @param version [String]
    # @return [self]
    def initialize(version)
      unless(version.to_s.match(/^\d+[.]?/))
        raise ArgumentError.new "Invalid version string! `#{version}`"
      end
      @version = version.to_s.gsub("-",".pre.").freeze
      @segments = @version.split('.').map do |part|
        if(part =~ /^\d+$/)
          part.to_i
        else
          part.scan(/\d+|[a-zA-Z]+/).map do |subpart|
            subpart =~ /^\d+$/ ? subpart.to_i : subpart.freeze
          end
        end
      end.flatten.compact.freeze
    end

    # @return [String]
    def version
      @version.dup
    end

    alias to_s version

    # @return [Integer] unique hash of instance
    def hash
      @version.hash
    end

    # @return [String] instance inspection
    def inspect
      "#<#{self.class} #{version.inspect}>"
    end

    # @return [TrueClass, FalseClass] version is a prerelease
    def prerelease?
      @_prerelease ||= !@version.match(/[a-zA-Z]/).nil?
    end

    # @return [Version] increment to next version
    def bump
      unless(@_bump)
        bump_segments = segments[0,
          segments.index{|s|
            s.is_a?(String)
          } || segments.size
        ]
        bump_segments.pop if bump_segments.size > 1
        bump_segments[-1] = bump_segments[-1].succ
        @_bump = self.class.new(bump_segments.join('.'))
      end
      @_bump
    end

    # @return [Version] release of version
    def release
      unless(@_release)
        if(prerelease?)
          @_release = self.class.new(
            segments[0,
              segments.index{|s|
                s.is_a?(String)
              }
            ].join('.')
          )
        else
          @_release = self
        end
      end
      @_release
    end

    # Compare against other version
    #
    # @param cmp_version [Version]
    # @return [Integer]
    def <=>(cmp_version)
      if(!cmp_version.is_a?(self.class))
        nil
      elsif(version == cmp_version.version)
        0
      else
        result = 0
        limit = [
          segments.size,
          cmp_version.segments.size
        ].max
        limit.times do |idx|
          lhs = segments.fetch(idx, 0)
          rhs = cmp_version.segments.fetch(idx, 0)
          if(lhs == rhs)
            next
          elsif(lhs.is_a?(String) && rhs.is_a?(Numeric))
            result = -1
          elsif(lhs.is_a?(Numeric) && rhs.is_a?(String))
            result = 1
          else
            result = lhs <=> rhs
          end
          break unless result.nil? || result == 0
        end
        result
      end
    end
  end

  # Current library version
  VERSION = Version.new('0.2.17')
end
