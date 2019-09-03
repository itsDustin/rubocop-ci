# frozen_string_literal: true

require 'rake'
require 'yaml'

require 'rubocop/rake_task'
require 'scss_lint/rake_task'
require 'coffeelint'
require 'slim_lint'
require 'slim_lint/rake_task'

rubocop_config = nil

def config_file(name)
  File.expand_path("../../../config/#{name}", __FILE__)
end

def check_standard
  # Unlock standard when https://github.com/standard/standard/issues/1328 gets resolved.
  install = "npm install eslint 'standard@<13' babel-eslint -g"
  sh install if ENV['CI']
  raise "Please install standard: #{install}" unless system('which standard')
end

def run_standard(options = nil)
  check_standard

  base_js_dirs = [
    'app/assets/javascripts',
    'app/javascript',
    'client/app',
    'client/lib'
  ]

  files = Dir["{#{base_js_dirs.join(',')}}/**/*.{js,jsx}"].join(' ')
  sh "standard #{options} --parser babel-eslint #{files}"
end

def run_i18n_lint(options = nil)
  files = Dir['config/locales/**/*.yml'].join(' ')
  sh "i18n-lint #{options} #{files}"
end

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = gem_config = config_file('rubocop.yml')
  todo_config = "#{Dir.pwd}/.rubocop_todo.yml"

  if File.exist?(todo_config)
    rubocop_config = Tempfile.new('rubocop')
    rubocop_config.write(YAML.dump('inherit_from' => [gem_config, todo_config.to_s]))
    rubocop_config.close
    config = rubocop_config.path
  end

  # SlimLint runs rubocop on .slim files. Ensure we use the same config for .rb and .slim files.
  ENV['SLIM_LINT_RUBOCOP_CONF'] = config

  task.options = ['-D', '-c', config]
  task.options << '-R' if defined?(Rails)
  if ENV['AUTOGEN']
    task.options << '--auto-gen-config'
    task.options << %w[--exclude-limit 1000]
  end
  task.requires = ['rubocop-rspec']
end

if Dir.exist?('app')
  scss_task = File.exist?("#{Dir.pwd}/.skip_scss_lint") ? :scss_lint : :rubocop
  SCSSLint::RakeTask.new(scss_task) do |task|
    task.config = config_file('scss-lint.yml')
    task.files = ['app/assets']
  end

  task :rubocop do
    config = File.expand_path('../../../config/coffeelint.json', __FILE__)
    failures = Coffeelint.run_test_suite('app', config_file: config)
    raise('Coffeelint fail!') if failures.positive?
  end

  SlimLint::RakeTask.new(:rubocop) do |task|
    task.config = config_file('slim-lint.yml')
    task.files = %w[app spec]
  end

  task :rubocop do
    run_standard
  end

  task :rubocop do
    success = system('bundle exec brakeman --no-pager')
    raise 'Brakeman Errors' unless success
  end

  task :rubocop do
    run_i18n_lint
  end

  task :rubocop do
    sh 'clockwork-lint'
  end

  namespace :rubocop do
    task :auto_correct do
      run_standard('--fix')
      run_i18n_lint('--fix')
    end
  end
end
