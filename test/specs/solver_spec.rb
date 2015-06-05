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
      @units = 20.times.map do |i|
        10.times.map do |j|
          Grimoire::Unit.new(
            :name => "unit#{i}",
            :version => "#{j}.0.0"
          )
        end
      end.flatten
      @system = Grimoire::System.new
      @system.add_unit(@units)
    end

    let(:units){ @units }
    let(:system){ @system }
    let(:generate_solver) do
      req = Grimoire::RequirementList.new(
        :name => 'test',
        :requirements => [
          ['unit1', '> 8'],
          ['unit2', '> 1']
        ]
      )
      Grimoire::Solver.new(:system => system, :requirements => req)
    end

    it 'should populate the world after initialization' do
      solver = generate_solver
      solver.world.class.must_equal Grimoire::System
      solver.world.units.keys.sort.must_equal ['unit1', 'unit2']
      solver.world.units['unit1'].size.must_equal 1
      solver.world.units['unit2'].size.must_equal 8
    end

    it 'should resolve dependencies within constraints' do
      result = generate_solver.generate!
      result.wont_be :empty?
      path = result.pop
      path.units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit2' && unit.version.to_s == '9.0.0'
      end.wont_be_nil
    end

    it 'should include all dependencies' do
      units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.dependencies = [
        ['unit2', '< 5'],
        ['unit6', '> 4', '< 9']
      ]
      result = generate_solver.generate!
      result.wont_be :empty?
      path = result.pop
      path.units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit2' && unit.version.to_s == '4.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit6' && unit.version.to_s == '8.0.0'
      end.wont_be_nil
    end

    it 'should handle circular dependencies' do
      units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.dependencies = [
        ['unit2', '< 5'],
        ['unit6', '> 4', '< 9']
      ]
      units.detect do |unit|
        unit.name == 'unit6' && unit.version.to_s == '8.0.0'
      end.dependencies = [
        ['unit1', '9']
      ]
      result = generate_solver.generate!
      result.wont_be :empty?
      path = result.pop
      path.units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit2' && unit.version.to_s == '4.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit6' && unit.version.to_s == '8.0.0'
      end.wont_be_nil
    end

    it 'should prune units not required for solutions' do
      units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.dependencies = [
        ['unit6', '> 5']
      ]
      solv = generate_solver
      solv.world.units['unit6'].size.must_equal 4
      solv.prune_world!
      solv.world.units['unit6'].size.must_equal 1
    end

    it 'should discard items when pruning that provide no solution' do
      units.detect do |unit|
        unit.name == 'unit2' && unit.version.to_s == '8.0.0'
      end.dependencies = [
        ['unit6', '> 5']
      ]
      units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '9.0.0'
      end.dependencies = [
        ['unit6', '> 20']
      ]
      solv = generate_solver
      solv.world.units['unit6'].size.must_equal 4
      solv.prune_world!
      solv.world.units['unit6'].size.must_equal 1
    end

    it 'should apply restrictions when solving requirements' do
      req = Grimoire::RequirementList.new(
        :name => 'test',
        :requirements => [
          ['unit1', '> 5'],
          ['unit2', '> 3']
        ]
      )
      restrict = Grimoire::RequirementList.new(
        :name => 'restrictions',
        :requirements => [
          ['unit1', '< 9'],
          ['unit1', '<= 7'],
          ['unit2', '> 4', '< 6']
        ]
      )
      solv = Grimoire::Solver.new(
        :system => system,
        :requirements => req,
        :restrictions => restrict
      )
      result = solv.generate!
      path = result.pop
      path.units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '7.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit2' && unit.version.to_s == '5.0.0'
      end.wont_be_nil
    end

    it 'should apply restrictions on dependencies when solving requirements' do
      req = Grimoire::RequirementList.new(
        :name => 'test',
        :requirements => [
          ['unit1', '> 5'],
          ['unit2', '> 3']
        ]
      )
      restrict = Grimoire::RequirementList.new(
        :name => 'restrictions',
        :requirements => [
          ['unit1', '< 9'],
          ['unit1', '<= 7'],
          ['unit2', '> 4', '< 6'],
          ['unit6', '< 6']
        ]
      )
      units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '7.0.0'
      end.dependencies = [
        ['unit6', '> 4', '< 9']
      ]
      solv = Grimoire::Solver.new(
        :system => system,
        :requirements => req,
        :restrictions => restrict
      )
      result = solv.generate!
      path = result.pop
      path.units.detect do |unit|
        unit.name == 'unit1' && unit.version.to_s == '7.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit2' && unit.version.to_s == '5.0.0'
      end.wont_be_nil
      path.units.detect do |unit|
        unit.name == 'unit6' && unit.version.to_s == '5.0.0'
      end.wont_be_nil
    end

  end
end
