require 'grimoire'
require 'minitest/autorun'

describe Grimoire::Unit do

  describe 'Usage' do
    before do
      @unit = Grimoire::Unit.new(
        :name => 'test',
        :version => Grimoire::VERSION_CLASS.new('0.0.1'),
        :dependencies => [['dep1', '> 0']]
      )
    end

    let(:unit){ @unit }

    it 'should provide the name' do
      unit.name.must_equal 'test'
    end

    it 'should provide the version' do
      unit.version.to_s.must_equal '0.0.1'
    end

    it 'should provide the list of dependencies' do
      unit.dependencies.must_equal [Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0')]
    end
  end

  describe 'Creation' do

    it 'should require a name' do
      ->{ Grimoire::Unit.new(:version => '0.1.1') }.must_raise ArgumentError
    end

    it 'should require a version' do
      ->{ Grimoire::Unit.new(:name => 'test') }.must_raise ArgumentError
    end

    it 'should accept a version' do
      Grimoire::Unit.new(
        :name => 'test',
        :version => Grimoire::VERSION_CLASS.new('0.1.1')
      ).version.must_equal Grimoire::VERSION_CLASS.new('0.1.1')
    end

    it 'should coerce a version string' do
      Grimoire::Unit.new(
        :name => 'test',
        :version => '0.1.1'
      ).version.must_equal Grimoire::VERSION_CLASS.new('0.1.1')
    end

    it 'should accept dependencies' do
      Grimoire::Unit.new(
        :name => 'test',
        :version => '0.1.1',
        :dependencies => [
          Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
          Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
        ]
      ).dependencies.must_equal [
        Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
        Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
      ]
    end

    it 'should coerce an array of dependency strings' do
      Grimoire::Unit.new(
        :name => 'test',
        :version => '0.1.1',
        :dependencies => [
          ['dep1', '> 0'],
          ['dep2', '> 0']
        ]
      ).dependencies.must_equal [
        Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
        Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
      ]
    end

  end

end
