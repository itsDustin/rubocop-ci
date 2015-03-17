module RubocopCi
  if defined?(Rails)
    class Railtie < Rails::Railtie
      railtie_name :rubocop_ci

      rake_tasks do
        load 'tasks/rubocop-ci.rake'
      end
    end
  end
end
