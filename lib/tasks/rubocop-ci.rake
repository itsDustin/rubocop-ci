require 'rubocop/rake_task'

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = File.expand_path('../../../rubocop.yml', __FILE__)

  task.options = ['-c', config]
  task.options << '-R' if defined?(Rails)
  task.requires = ['rubocop-rspec']
end
