require 'rubocop/rake_task'

desc 'Runs rubocop with our custom settings'
RuboCop::RakeTask.new(:rubocop) do |task|
  config = File.expand_path('../../../rubocop.yml', __FILE__)

  task.options = ['-R', '-c', config]
  task.patterns = ['{app,config,lib,spec}/**/*.rb']
end
