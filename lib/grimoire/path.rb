require 'grimoire'

module Grimoire
  # Constraint resolution path
  class Path < Utility

    attribute :units, Unit, :multiple => true, :default => []

    def dependencies
      units.map(&:dependencies).flatten.uniq!
    end

  end
end
