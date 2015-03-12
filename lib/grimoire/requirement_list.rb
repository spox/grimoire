require 'grimoire'

module Grimoire

  # Requirment list for solver
  class RequirementList < Utility
    attribute :name, String, :required => true, :coerce => lambda{|val| val.to_s}
    attribute :requirements, DEPENDENCY_CLASS, :multiple => true, :default => [], :coerce => lambda{|val| Grimoire.const_get(:DEPENDENCY_CLASS).new(val.first, *val.last)}
  end

end
