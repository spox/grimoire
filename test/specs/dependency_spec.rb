require_relative '../helper'

describe Grimoire::Dependency do
  describe '#prerelease?' do
    it 'should be a prerelease when explicitly set' do
      dep = Grimoire::Dependency.new('dep')
      dep.prerelease = true
      dep.prerelease?.must_equal true
    end

    it 'should be a prerelease when requirement is prerelease' do
      dep = Grimoire::Dependency.new('dep', '>= 0.1.0.pre')
      dep.prerelease?.must_equal true
    end

    it 'should not be a prerelease when no prerelease set' do
      dep = Grimoire::Dependency.new('dep')
      dep.prerelease.must_equal false
    end
  end

  describe '#==' do
    it 'should be equal to dependency with same name' do
      Grimoire::Dependency.new('dep').must_equal Grimoire::Dependency.new('dep')
    end

    it 'should be equal to dependency with same name and requirements' do
      Grimoire::Dependency.new('dep', '> 1').must_equal(
        Grimoire::Dependency.new('dep', '> 1')
      )
    end

    it 'should be equal to dependency with same name and equivalent requirements' do
      Grimoire::Dependency.new('dep', '> 1').must_equal(
        Grimoire::Dependency.new('dep', '> 1.0')
      )
    end

    it 'should not be equal to dependency with same name and different requirements' do
      Grimoire::Dependency.new('dep', '> 1').wont_equal(
        Grimoire::Dependency.new('dep', '> 2')
      )
    end

    it 'should not be equal to dependency with different name and same requirements' do
      Grimoire::Dependency.new('dep1', '> 1').wont_equal(
        Grimoire::Dependency.new('dep', '> 1')
      )
    end
  end

  describe '#<=>' do
    it 'should sort dependencies by name' do
      d1, d2, d3 = Grimoire::Dependency.new('dep1'),
        Grimoire::Dependency.new('dep2'),
        Grimoire::Dependency.new('dep3')
      [d3, d1, d2].sort.must_equal [d1, d2, d3]
    end
  end

  describe '#merge' do
    it 'should merge two dependencies' do
      d1 = Grimoire::Dependency.new('d1', '>= 1.0.0')
      d2 = Grimoire::Dependency.new('d1', '< 2.0.0')
      d1.merge(d2).must_equal Grimoire::Dependency.new('d1', '>= 1.0.0', '< 2.0.0')
    end
  end
end
