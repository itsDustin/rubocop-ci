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

  rubocop_config = new_tempfile
  rubocop_config.write(YAML.dump('inherit_from' => config_files))
  rubocop_config.close
  rubocop_config.path
end

def new_tempfile
  @tempfiles ||= []
  @tempfiles << Tempfile.new('rubocop')
  @tempfiles.last
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

desc 'DEPRECATED: Run all linters'
# TODO: Delete on next major release
task rubocop: %i[rubocop_ci:rubocop] +
  if Dir.exist?('app')
    [
      (:'rubocop_ci:scss_lint' unless File.exist?("#{Dir.pwd}/.skip_scss_lint")),
      :'rubocop_ci:slim_lint',
      :'rubocop_ci:coffee_lint',
      :'rubocop_ci:javascript_lint',
      :'rubocop_ci:brakeman',
      :'rubocop_ci:i18n_lint',
      :'rubocop_ci:clockwork_lint'
    ].compact
  else
    []
  end

desc 'DEPRECATED: Run linters that are auto-correct capable'
# TODO: Delete on next major release
namespace :rubocop do
  task auto_correct: :'rubcocop_ci:auto_correct'
end

namespace :rubocop_ci do # rubocop:disable Metrics/BlockLength
  desc 'Runs rubocop with our custom settings'
  RuboCop::RakeTask.new(:rubocop) do |task|
    config = generate_rubocop_config(todo: true)

    # SlimLint runs rubocop on .slim files. Ensure we use the same config for
    # .rb and .slim files.
    ENV['SLIM_LINT_RUBOCOP_CONF'] = config

    task.options = ['-D', '-c', config]
    if ENV['AUTOGEN']
      task.options << '--auto-gen-config'
      task.options << %w[--exclude-limit 1000]
    end
    logger.info("rubocop #{task.options.join(' ')}")
  end

  desc 'Runs rubocop-git with our custom settings'
  namespace :rubocop do
    task :diff, %i[reference_branch] do |_task, args|
      require 'rubocop/git/cli'
      config = generate_rubocop_config(todo: false)
      reference_branch = args[:reference_branch] || 'origin/master...'
      options = ['-D', '-c', config, reference_branch]
      logger.info("rubocop-git #{options.join(' ')}")
      RuboCop::Git::CLI.new.run(options)
    end
  end

  desc 'Run linters that are auto-correct capable'
  task :auto_correct do
    run_standard('--fix')
    run_i18n_lint('--fix')
  end

  desc 'Run SCSS linter'
  SCSSLint::RakeTask.new(:scss_lint) do |task|
    task.config = config_file('scss-lint.yml')
    task.files = ['app/assets']
  end

  desc 'Run CoffeeScript linter'
  task :coffee_lint do
    config = File.expand_path('../../config/coffeelint.json', __dir__)
    failures = Coffeelint.run_test_suite('app', config_file: config)
    raise('Coffeelint fail!') if failures.positive?
  end

  desc 'Run slim linter'
  SlimLint::RakeTask.new(:slim_lint) do |task|
    task.config = config_file('slim-lint.yml')
    task.files = %w[app spec]
  end

  desc 'Run javascript linter'
  task :javascript_lint do
    run_standard
  end

  desc 'Run brakeman'
  task :brakeman do
    success = system('bundle exec brakeman --no-pager')
    raise 'Brakeman Errors' unless success
  end

  desc 'Run i18n linter'
  task :i18n_lint do
    run_i18n_lint
  end

  desc 'Run clockwork.rb linter'
  task :clockwork_lint do
    sh 'clockwork-lint'
  end
end
