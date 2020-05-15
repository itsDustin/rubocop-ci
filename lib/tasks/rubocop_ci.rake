# frozen_string_literal: true

require 'rake'
require 'yaml'
require 'tempfile'
require 'logger'

require 'rubocop/rake_task'
require 'scss_lint/rake_task'
require 'coffeelint'
require 'slim_lint'
require 'slim_lint/rake_task'

def logger
  return @logger if @logger

  @logger = Logger.new($stdout)
  @logger.formatter = ->(_, _, _, msg) { "rubocop-ci: #{msg}\n" }
  @logger
end

def config_file(name)
  File.expand_path("../../../config/#{name}", __FILE__)
end

def check_standard
  # Unlock standard when https://github.com/standard/standard/issues/1328 gets resolved.
  install = "npm install 'standard@<13' babel-eslint eslint -g"
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

def generate_rubocop_config(todo:)
  config_files = []
  config_files << config_file('rubocop.yml')

  config_files = include_rails_config(config_files)
  config_files = include_todo_config(config_files) if todo

  rubocop_config = Tempfile.new('rubocop')
  rubocop_config.write(YAML.dump('inherit_from' => config_files))
  rubocop_config.close
  rubocop_config.path
end

def include_rails_config(config_files)
  if defined?(Rails)
    logger.info('Rails is present, including Rails cops')
    config_files + [config_file('rubocop_rails.yml')]
  else
    logger.info('Rails is not present, not including Rails cops')
    config_files
  end
end

def include_todo_config(config_files)
  todo_config = Pathname.new(Dir.pwd).join('.rubocop_todo.yml')
  if File.exist?(todo_config)
    logger.info('.rubocop_todo.yml found, including it')
    config_files + [todo_config.to_s]
  else
    logger.info('No .rubocop_todo.yml found 🌞')
    config_files
  end
end

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = generate_rubocop_config(todo: true)

  # SlimLint runs rubocop on .slim files. Ensure we use the same config for .rb and .slim files.
  ENV['SLIM_LINT_RUBOCOP_CONF'] = config

  task.options = ['-D', '-c', config]
  if ENV['AUTOGEN']
    task.options << '--auto-gen-config'
    task.options << %w[--exclude-limit 1000]
  end
  logger.info("rubocop #{task.options.join(' ')}")
end

desc 'Runs rubocop-git with our custom settings'
task :rubocop_diff do |_task|
  require 'rubocop/git/cli'
  config = generate_rubocop_config(todo: false)
  options = ['-D', '-c', config]
  logger.info("rubocop-git #{options.join(' ')}")
  RuboCop::Git::CLI.new.run(options)
end

if Dir.exist?('app')
  scss_task = File.exist?("#{Dir.pwd}/.skip_scss_lint") ? :scss_lint : :rubocop
  SCSSLint::RakeTask.new(scss_task) do |task|
    task.config = config_file('scss-lint.yml')
    task.files = ['app/assets']
  end

  task :rubocop do
    config = File.expand_path('../../config/coffeelint.json', __dir__)
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
