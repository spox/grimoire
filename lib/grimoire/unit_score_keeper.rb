require 'grimoire'

module Grimoire
  class UnitScoreKeeper < Utility

    # Provide score for given unit
    #
    # @param unit [Unit]
    # @param idx [Integer] current order index
    # @return [Numeric]
    def score_for(unit, idx)
      raise NotImplementedError.new 'No scoring has been defined'
    end

  end
end
