$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'grimoire/version'
Gem::Specification.new do |s|
  s.name = 'grimoire'
  s.version = Grimoire::VERSION.version
  s.summary = 'Constraint solver'
  s.author = 'Chris Roberts'
  s.email = 'code@chrisroberts.org'
  s.homepage = 'https://github.com/spox/grimoire'
  s.description = 'Specialized constraint solver allowing weighted results'
  s.require_path = 'lib'
  s.license = 'Apache 2.0'
  s.add_runtime_dependency 'bogo', '>= 0.1.10', '< 1.0'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 10'
  s.files = Dir['{lib}/**/**/*'] + %w(grimoire.gemspec README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
end
