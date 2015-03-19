require 'bogo'

module Grimoire
  # @todo Provide abstract interfaces for these and run validation on
  #       defined classes to ensure expected methods

  # Class used to define version information
  VERSION_CLASS = Gem::Version
  # Class used to define dependency information
  DEPENDENCY_CLASS = Gem::Dependency
  # Class used to define requirement
  REQUIREMENT_CLASS = Gem::Requirement

  autoload :Error, 'grimoire/error'
  autoload :Path, 'grimoire/path'
  autoload :RequirementList, 'grimoire/requirement_list'
  autoload :Solver, 'grimoire/solver'
  autoload :System, 'grimoire/system'
  autoload :Unit, 'grimoire/unit'
  autoload :UnitScoreKeeper, 'grimoire/unit_score_keeper'
  autoload :Utility, 'grimoire/utility'

  class << self

    # @return [Bogo::Ui]
    attr_reader :ui

    # Set Ui instance
    #
    # @param ui [Bogo::Ui]
    # @return [Bogo::Ui]
    def ui=(ui)
      unless(ui.respond_to?(:debug))
        raise TypeError.new "Expecting type `Bogo::Ui` but received `#{ui.class}`"
      end
      @ui = ui
    end


    # Write debug message
    def debug(*args)
      if(ui)
        if(block_given?)
          args.push(yield)
        end
        ui.debug(*args)
      end
    end
  end

end

require 'grimoire/version'
