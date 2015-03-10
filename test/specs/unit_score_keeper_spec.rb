require 'grimoire'
require 'minitest/autorun'

describe Grimoire::UnitScoreKeeper do

  it 'should respond to #score_for' do
    ->{
      Grimoire::UnitScoreKeeper.new.score_for(
        Grimoire::Unit.new(
          :name => 'test',
          :version => '0.1.1'
        )
      )
    }.must_raise NotImplementedError
  end

end
