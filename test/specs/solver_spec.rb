require 'grimoire'
require 'minitest/autorun'

describe Grimoire::Solver do

  describe 'Creation' do

    before do
      @system = Grimoire::System.new
    end

    let(:system){ @system }

    it 'should require a requirements list' do
      ->{ Grimoire::Solver.new(:system => system) }.must_raise ArgumentError
    end

    it 'should require a system' do
      ->{
        Grimoire::Solver.new(
          :requirements => Grimoire::RequirementList.new(
            :name => 'test',
            :requirements => [
              ['dep1', '> 0']
            ]
          )
        )
      }.must_raise ArgumentError
    end

  end

  describe 'Usage' do

    before do
      @system = Grimoire::System.new
    end

    let(:system){ @system }

    it 'should populate the world after initialization' do

    end

  end

end
