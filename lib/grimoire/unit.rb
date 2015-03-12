require 'grimoire'

module Grimoire

  # Defines a specific unit in the system
  class Unit < Utility

    attribute :name, String, :required => true
    attribute :dependencies, DEPENDENCY_CLASS, :multiple => true, :default => [], :coerce => lambda{|val| Grimoire.const_get(:DEPENDENCY_CLASS).new(val.first, *val.last)}
    attribute :version, VERSION_CLASS, :required => true, :coerce => lambda{|val| Grimoire.const_get(:VERSION_CLASS).new(val)}

  end

end
