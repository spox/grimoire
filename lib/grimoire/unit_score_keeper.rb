require 'grimoire'

module Grimoire
  class UnitScoreKeeper < Utility

    # Provide score for given unit
    #
    # @param unit [Unit]
    # @return [Numeric]
    def score_for(unit)
      raise NotImplementedError.new 'No scoring has been defined'
    end

  end
end
