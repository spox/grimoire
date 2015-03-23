require 'grimoire'

module Grimoire
  class UnitScoreKeeper < Utility

    # Define meaning of score by what should be preferred. This is
    # used by the solver to apply correct sorting to the queues.
    #
    # @return [Symbol] :lowscore or :highscore
    def preferred_score
      :lowscore
    end

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
