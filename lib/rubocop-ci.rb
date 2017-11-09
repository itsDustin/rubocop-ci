# rubocop:disable Naming/FileName
# frozen_string_literal: true

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
