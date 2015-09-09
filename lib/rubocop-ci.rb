# rubocop:disable Style/FileName

module RubocopCi
  BUNLDED_CONFIG_DIR = File.expand_path('../../config', __FILE__)
  RUBOCOP_KNOWN_CONFIGS = %w(.rubocop_todo.yml .rubocop.yml).map { |name| "#{Dir.pwd}/#{name}" }

  def self.rubocop_local_configs
    RUBOCOP_KNOWN_CONFIGS.select { |config| File.exist?(config) }
  end

  def self.rubocop_all_configs
    [bundled_config('rubocop.yml')] + rubocop_local_configs
  end

  def self.bundled_config(name)
    File.join(BUNLDED_CONFIG_DIR, name)
  end
end

# Only load the rake task when we actually run the rake command.
# If Rails is present, the Railtie ensures this.
# If there is no Rails, we have to include rubocop-ci manually in the Rakefile anyway.
if defined?(Rails)
  class RubocopCiRailtie < Rails::Railtie
    rake_tasks { load 'tasks/rubocop-ci.rake' }
  end
else
  load 'tasks/rubocop-ci.rake'
end

