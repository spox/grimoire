require_relative '../helper'

describe Grimoire::Version do

  describe 'instance creation' do
    it 'should create with three segments' do
      Grimoire::Version.new('0.0.1').is_a?(Grimoire::Version)
    end

    it 'should create with three segments' do
      Grimoire::Version.new('0.1').is_a?(Grimoire::Version)
    end

    it 'should create with three segments' do
      Grimoire::Version.new('1').is_a?(Grimoire::Version)
    end

    it 'should fail when segment is invalid' do
      ->{ Grimoire::Version.new('ack') }.must_raise(ArgumentError)
    end
  end

  describe 'instance comparison' do
    describe 'equivalence' do
      it 'should be true when version strings are same' do
        Grimoire::Version.new('1.0.0').must_equal(
          Grimoire::Version.new('1.0.0')
        )
      end

      it 'should be true when version strings are not equal segments' do
        Grimoire::Version.new('1.0').must_equal(Grimoire::Version.new('1.0.0'))
        Grimoire::Version.new('1').must_equal(Grimoire::Version.new('1.0.0'))
        Grimoire::Version.new('1.0.0').must_equal(Grimoire::Version.new('1.0'))
        Grimoire::Version.new('1.0.0').must_equal(Grimoire::Version.new('1'))
        Grimoire::Version.new('1.0').must_equal(Grimoire::Version.new('1'))
        Grimoire::Version.new('1').must_equal(Grimoire::Version.new('1.0'))
      end
    end

    describe 'less than' do
      it 'should be less than version greater than itself' do
        Grimoire::Version.new('1.0.0').must_be :<, Grimoire::Version.new('1.0.1')
        Grimoire::Version.new('1.0.0').must_be :<, Grimoire::Version.new('1.1')
        Grimoire::Version.new('1.0.0').must_be :<, Grimoire::Version.new('2')
      end

      it 'should not be less than version equal to itself' do
        Grimoire::Version.new('1.0.0').wont_be :<, Grimoire::Version.new('1.0.0')
      end
    end

    describe 'greater than' do
      it 'should be greater than version less than itself' do
        Grimoire::Version.new('1.0.0').must_be :>, Grimoire::Version.new('0.0.1')
        Grimoire::Version.new('1.0.0').must_be :>, Grimoire::Version.new('0.1')
        Grimoire::Version.new('1.0.0').must_be :>, Grimoire::Version.new('0')
      end

      it 'should not be greater than version equal to itself' do
        Grimoire::Version.new('1.0.0').wont_be :>, Grimoire::Version.new('1.0.0')
      end
    end

    describe 'less than or equal to' do
      it 'should be less than version greater than itself' do
        Grimoire::Version.new('1.0.0').must_be :<=, Grimoire::Version.new('1.0.1')
        Grimoire::Version.new('1.0.0').must_be :<=, Grimoire::Version.new('1.1')
        Grimoire::Version.new('1.0.0').must_be :<=, Grimoire::Version.new('2')
      end

      it 'should be less than or equal to version equal to itself' do
        Grimoire::Version.new('1.0.0').must_be :<=, Grimoire::Version.new('1.0.0')
      end
    end

    describe 'greater than or equal to' do
      it 'should be greater than or equal to version less than itself' do
        Grimoire::Version.new('1.0.0').must_be :>=, Grimoire::Version.new('0.0.1')
        Grimoire::Version.new('1.0.0').must_be :>=, Grimoire::Version.new('0.1')
        Grimoire::Version.new('1.0.0').must_be :>=, Grimoire::Version.new('0')
      end

      it 'should be greater than or equal to version equal to itself' do
        Grimoire::Version.new('1.0.0').must_be :>=, Grimoire::Version.new('1.0.0')
      end
    end
  end
end
