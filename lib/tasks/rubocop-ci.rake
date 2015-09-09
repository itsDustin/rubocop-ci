require 'rake'
require 'psych'

require 'rubocop/rake_task'
require 'scss_lint/rake_task'
require 'coffeelint'
require 'slim_lint'
require 'slim_lint/rake_task'
require 'brakeman'

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = Tempfile.new('rubocop').path
  File.open(config, 'w') do |file|
    file.write({ 'inherit_from' => RubocopCi.rubocop_all_configs }.to_yaml)
  end

  # SlimLint runs rubocop on .slim files. Ensure we use the same config for .rb and .slim files.
  ENV['SLIM_LINT_RUBOCOP_CONF'] = config

  task.options = ['-D', '-c', config]
  task.options << '-R' if defined?(Rails)
  task.options << '--auto-gen-config' if ENV['AUTOGEN']
  task.requires = ['rubocop-rspec']
end

if Dir.exist?('app')
  scss_task = File.exist?("#{Dir.pwd}/.skip_scss_lint") ? :scss_lint : :rubocop
  SCSSLint::RakeTask.new(scss_task) do |task|
    task.config = RubocopCi.bundled_config('scss-lint.yml')
    task.files = ['app/assets']
  end

  task :rubocop do
    config = RubocopCi.bundled_config('coffeelint.json')
    Coffeelint.run_test_suite('app', config_file: config) || fail('Coffeelint fail!')
  end

  SlimLint::RakeTask.new(:rubocop) do |task|
    task.config = RubocopCi.bundled_config('slim-lint.yml')
    task.files = %w(app spec)
  end

  task :rubocop do
    install = 'npm install standard -g'
    sh install if ENV['CI']
    fail "Please install standard: #{install}" unless system('which standard')

    sh 'standard'
  end

  task :rubocop do
    result = Brakeman.run(app_path: '.', exit_on_warn: true)
    ignored = result.ignored_filter ? result.ignored_filter.ignored_warnings : []
    errors = result.errors + result.warnings - ignored

    if errors.empty?
      puts 'Brakeman OK'
    else
      puts result.report.to_s
      fail 'Brakeman Errors'
    end
  end
end
