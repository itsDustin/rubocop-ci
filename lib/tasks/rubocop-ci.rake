require 'rubocop/rake_task'

require 'scss_lint/rake_task'

require 'coffeelint'

require 'slim_lint'
require 'slim_lint/rake_task'

require 'eslint'

rubocop_config = nil

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = gem_config = File.expand_path('../../../config/rubocop.yml', __FILE__)
  todo_config = "#{Dir.pwd}/.rubocop_todo.yml"

  if File.exist?(todo_config)
    rubocop_config = Tempfile.new('rubocop')
    rubocop_config.write({ 'inherit_from' => [gem_config, todo_config.to_s] }.to_yaml)
    rubocop_config.close
    config = rubocop_config.path
  end

  task.options = ['-D', '-c', config]
  task.options << '-R' if defined?(Rails)
  task.options << '--auto-gen-config' if ENV['AUTOGEN']
  task.requires = ['rubocop-rspec']
end

if Dir.exists?('app')
  task :rubocop do
    eslint = Eslint.new(config: File.expand_path('../../../config/eslint.json', __FILE__))
    next eslint.run if eslint.executable_exists?
    puts 'Warning: the eslint executable could not be found (npm install -g eslint)'
  end

  scss_task = File.exists?("#{Dir.pwd}/.skip_scss_lint") ? :scss_lint : :rubocop
  SCSSLint::RakeTask.new(scss_task) do |task|
    task.config = File.expand_path('../../../config/scss-lint.yml', __FILE__)
    task.files = ['app/assets']
  end

  task :rubocop do
    config = File.expand_path('../../../config/coffeelint.json', __FILE__)
    Coffeelint.run_test_suite('app', config_file: config) || fail('Coffeelint fail!')
  end

  SlimLint::RakeTask.new(:rubocop) do |task|
    task.config = File.expand_path('../../../config/slim-lint.yml', __FILE__)
    task.files = ['app', 'spec']
  end
end
