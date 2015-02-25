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

  end

end
