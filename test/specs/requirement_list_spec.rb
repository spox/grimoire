require_relative '../helper'

describe Grimoire::RequirementList do

  before do
    @req = Grimoire::RequirementList.new(
      :name => 'test',
      :requirements => [
        ['dep1', '> 0'],
        ['dep2', '> 0']
      ]
    )
  end

  let(:req){ @req }

  it 'should provide a name' do
    req.name.must_equal 'test'
  end

  it 'should provide requirements' do
    req.requirements.must_equal [
      Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
      Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
    ]
  end

  it 'should require a name' do
    ->{ Grimoire::RequirementList.new }.must_raise ArgumentError
  end

  it 'should accept list of dependency instances for requirements' do
    req.requirements.must_equal [
      Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
      Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
    ]
  end

  it 'should coerce list of strings for requirements' do
    r = Grimoire::RequirementList.new(
      :name => 'test',
      :requirements => [
        Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
        Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
      ]
    )
    r.requirements.must_equal [
      Grimoire::DEPENDENCY_CLASS.new('dep1', '> 0'),
      Grimoire::DEPENDENCY_CLASS.new('dep2', '> 0')
    ]
  end

end
