require 'grimoire'

module Grimoire

  # Base class for building utility objects
  class Utility

    # Provide lazy setup helpers
    include Bogo::Lazy

    # Disable data state
    always_clean!

    # Force load on init to enforce rules
    def initialize(args={})
      load_data(args)
    end

    # @return [String] JSON serialized
    def to_json(*args)
      MultiJson.dump(data, *args)
    end

    # Write debug message
    def debug(*args, &block)
      Grimoire.debug(*args, &block)
    end

  end

end
