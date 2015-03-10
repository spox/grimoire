require 'grimoire'
require 'minitest/autorun'

describe Grimoire::Path do

  before do
    @units = [
      Grimoire::Unit.new(
        :name => 'test1',
        :version => Grimoire::VERSION_CLASS.new('0.0.1'),
        :dependencies => [['dep1', '> 0']]
      ),
      Grimoire::Unit.new(
        :name => 'test2',
        :version => Grimoire::VERSION_CLASS.new('0.0.1'),
        :dependencies => [['dep2', '> 0']]
      )

    ]
    @path = Grimoire::Path.new(:units => @units)
  end

  let(:units){ @units }
  let(:path){ @path }

  it 'should provide list of units' do
    path.units.must_equal units
  end

  it 'should provide all dependencies within units' do
    path.dependencies.must_equal [
      Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
      Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
    ]
  end

end
