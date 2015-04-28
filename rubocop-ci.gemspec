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
  s.add_dependency 'psych'
  s.add_dependency 'rubocop'
  s.add_dependency 'rubocop-rspec'
  s.add_dependency 'scss-lint'
  s.add_dependency 'coffeelint'
end
