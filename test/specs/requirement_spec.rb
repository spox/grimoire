describe Grimoire::Requirement do
  describe '.parse' do
    it 'should parse a Version instance' do
      req = Grimoire::Requirement.parse(Grimoire::Version.new('1.0.0'))
      req.must_equal ['=', Grimoire::Version.new('1.0.0')]
    end

    it 'should parse a String' do
      req = Grimoire::Requirement.parse('> 1.0.0')
      req.must_equal ['>', Grimoire::Version.new('1.0.0')]
    end

    it 'should parse an Array of String and Version' do
      req = Grimoire::Requirement.parse(['>', Grimoire::Version.new('1.0.0')])
      req.must_equal ['>', Grimoire::Version.new('1.0.0')]
    end

    it 'should parse an Array of Strings' do
      req = Grimoire::Requirement.parse(['>', '1.0.0'])
      req.must_equal ['>', Grimoire::Version.new('1.0.0')]
    end
  end

  describe '#satisfied_by?' do
    it 'should be satisfied by version within requirement' do
      Grimoire::Requirement.new('> 1').satisfied_by?(
        Grimoire::Version.new('1.0.1')
      ).must_equal true
    end

    it 'should not be satisfied by version outside requirement' do
      Grimoire::Requirement.new('> 1').satisfied_by?(
        Grimoire::Version.new('0.2.1')
      ).wont_equal true
    end

    it 'should be satisfied by version within two requirements' do
      Grimoire::Requirement.new('> 1', '< 2').satisfied_by?(
        Grimoire::Version.new('1.2.1')
      ).must_equal true
    end

    it 'should be satisified by version within optimistic requirement' do
      Grimoire::Requirement.new('~> 1.0.0').satisfied_by?(
        Grimoire::Version.new('1.0.2')
      ).must_equal true
    end

    it 'should not be satisfied by version not within optimistic requirement' do
      Grimoire::Requirement.new('~> 1.0.3').satisfied_by?(
        Grimoire::Version.new('1.0.2')
      ).wont_equal true
    end
  end
end
