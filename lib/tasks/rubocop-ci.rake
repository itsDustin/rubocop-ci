require 'rubocop/rake_task'
require 'scss_lint/rake_task'
require 'coffeelint'

rubocop_config = nil

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = gem_config = File.expand_path('../../../rubocop.yml', __FILE__)
  todo_config = "#{Dir.pwd}/.rubocop_todo.yml"

  if File.exist?(todo_config)
    rubocop_config = Tempfile.new('rubocop')
    rubocop_config.write({ 'inherit_from' => [gem_config, todo_config.to_s] }.to_yaml)
    rubocop_config.close
    config = rubocop_config.path
  end

  task.options = ['-c', config]
  task.options << '-R' if defined?(Rails)
  task.options << '--auto-gen-config' if ENV['AUTOGEN']
  task.requires = ['rubocop-rspec']
end


if defined?(Rails)
  scss_task = File.exists?("#{Dir.pwd}/.skip_scss_lint") ? :scss_lint : :rubocop
  SCSSLint::RakeTask.new(scss_task) do |task|
    task.config = File.expand_path('../../../scss-lint.yml', __FILE__)
    task.files = ['app/assets']
  end

  task :rubocop do
    config = File.expand_path('../../../coffeelint.json', __FILE__)
    Coffeelint.run_test_suite('app', config_file: config) || fail('Coffeelint fail!')
  end
end
