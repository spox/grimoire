require 'grimoire'

module Grimoire

  # General error
  class Error < StandardError
    # Requested unit is unavailable
    class UnitUnavailable < Error
      attr_accessor :unit_name
    end
    # Resolution path is not valid within constraints
    class ResolutionPathInvalid < Error; end
    # Too many loops run during path generation
    class MaximumGenerationLoopsExceeded < Error; end
    # No valid solution available
    class NoSolution < Error; end
  end

end
