# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.0'
  spec.name        = 'rubocop-ci'
  spec.version     = '1.0.3'
  spec.summary     = 'Runs rubocop with our settings'
  spec.description = ''
  spec.authors     = ['Combostrike GmbH']
  spec.email       = 'developers@combostrike.com'
  spec.files       = Dir['lib/**/*', 'exe/**/*']
  spec.bindir      = 'exe'
  spec.executables = %w[i18n-lint clockwork-lint]
  spec.homepage    = 'http://www.combostrike.com'
  spec.license     = ''

  spec.add_dependency 'coffeelint', '~> 1.16.0'
  spec.add_dependency 'cs-rubocop-git'
  spec.add_dependency 'rake', '>= 0.13'
  spec.add_dependency 'rubocop', '~> 1.18'
  spec.add_dependency 'rubocop-performance'
  spec.add_dependency 'rubocop-rails', '~> 2.11.3'
  spec.add_dependency 'rubocop-rspec', '= 1.19.0' # hard lock, they break semver promises
  spec.add_dependency 'scss_lint', '~> 0.59.0'
  spec.add_dependency 'slim_lint', '~> 0.22.0'

  # Use brakeman with less dependencies, but still have nice output
  spec.add_dependency 'brakeman-min', '~> 5.1.1'
  spec.add_dependency 'highline'
  spec.add_dependency 'terminal-table'
end
