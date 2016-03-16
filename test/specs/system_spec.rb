require_relative '../helper'

describe Grimoire::System do

  before do
    @system = Grimoire::System.new
  end

  let(:system){ @system }

  it 'should provide an empty units collection' do
    system.units.must_equal Smash.new
  end

  it 'should allow units to be added' do
    system.add_unit(
      Grimoire::Unit.new(:name => 't', :version => '0.0.1')
    )
    system.units.keys.must_include 't'
    system.units.values.first.size.must_equal 1
    system.units.values.first.first.class.must_equal Grimoire::Unit
    system.units.values.first.first.name.must_equal 't'
  end

  it 'should allow multiple units to be added' do
    system.add_unit(
      Grimoire::Unit.new(:name => 't', :version => '0.0.1'),
      Grimoire::Unit.new(:name => 't', :version => '0.1.1'),
      Grimoire::Unit.new(:name => 't', :version => '0.2.1'),
      Grimoire::Unit.new(:name => 't', :version => '0.3.1')
    )
    system.units['t'].size.must_equal 4
  end

  it 'should allow units to be removed' do
    unit = Grimoire::Unit.new(:name => 't', :version => '0.0.1')
    system.add_unit(unit)
    system.units.keys.must_include 't'
    system.units.values.first.size.must_equal 1
    system.remove_unit(unit)
    system.units.keys.wont_include 't'
  end

  it 'should error when adding a non-unit' do
    ->{ system.add_unit('hi') }.must_raise TypeError
  end

  it 'should error when removing a non-unit' do
    ->{ system.remove_unit('hi') }.must_raise TypeError
  end

  it 'should not error when removing item not within system' do
    system.remove_unit(Grimoire::Unit.new(:name => 't', :version => '1')).must_equal system
  end

  it 'should organize units by name' do
    system.add_unit(Grimoire::Unit.new(:name => 't', :version => '1'))
    system.add_unit(Grimoire::Unit.new(:name => 'a', :version => '1'))
    system.add_unit(Grimoire::Unit.new(:name => 'a', :version => '2'))
    system.units['t'].size.must_equal 1
    system.units['a'].size.must_equal 2
  end

  it 'should return a subset based on constraint' do
    system.add_unit(Grimoire::Unit.new(:name => 't', :version => '1'))
    system.add_unit(Grimoire::Unit.new(:name => 'a', :version => '1'))
    system.add_unit(match_unit = Grimoire::Unit.new(:name => 'a', :version => '2'))
    system.subset('a', Grimoire::REQUIREMENT_CLASS.new('>= 2')).must_equal [match_unit]
  end

  it 'should return an empty subset when no units match constraint' do
    system.add_unit(Grimoire::Unit.new(:name => 't', :version => '1'))
    system.add_unit(Grimoire::Unit.new(:name => 'a', :version => '1'))
    system.add_unit(match_unit = Grimoire::Unit.new(:name => 'a', :version => '2'))
    system.subset('a', Grimoire::REQUIREMENT_CLASS.new('>= 3')).must_equal []
  end

  it 'should remove duplicates after scrubbing' do
    t_unit = Grimoire::Unit.new(:name => 't', :version => '1')
    a_unit = Grimoire::Unit.new(:name => 'a', :version => '1')
    system.add_unit(t_unit)
    system.add_unit(a_unit)
    system.add_unit(t_unit)
    system.add_unit(a_unit)
    system.scrub!
    system.units['t'].must_equal [t_unit]
    system.units['a'].must_equal [a_unit]
  end

end
