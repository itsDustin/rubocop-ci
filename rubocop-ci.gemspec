# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'rubocop-ci'
  s.version     = '1.0.0'
  s.date        = '2015-03-17'
  s.summary     = 'Runs rubocop with our settings'
  s.description = ''
  s.authors     = ['ad2games GmbH']
  s.email       = 'developers@ad2games.com'
  s.files       = Dir['lib/**/*']
  s.homepage    = 'http://www.ad2games.com'
  s.license     = ''

  s.add_dependency 'rake'
  s.add_dependency 'rubocop', '~> 0.42.0'
  s.add_dependency 'rubocop-rspec', '~> 1.5.1'
  s.add_dependency 'scss_lint', '~> 0.49.0'
  s.add_dependency 'coffeelint', '~> 1.14.0'
  s.add_dependency 'slim_lint', '~> 0.8.1'

  # Use brakeman with less dependencies, but still have nice output
  s.add_dependency 'brakeman-min', '~> 3.3.3'
  s.add_dependency 'terminal-table'
  s.add_dependency 'highline'
end
