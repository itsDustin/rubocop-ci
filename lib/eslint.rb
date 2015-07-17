require 'mkmf'

class Eslint
  attr_reader :options

  DEFAULTS = {
    files: 'app',
    extensions: %w(.js .jsx),
  }

  def initialize(options = {})
    @options = DEFAULTS.merge(options)
  end

  def executable_exists?
    executable.present?
  end

  def executable
    @executable ||= find_executable('eslint')
  end

  def pathspec
    Array.wrap(options[:files]).join(' ')
  end

  def extensions
    options[:extensions].map { |e| "--ext #{e}" }.join(' ')
  end

  def config
    options.fetch(:config)
  end

  def run
    fail('eslint executable could not be found') unless executable_exists?
    system("#{executable} --config #{config} #{extensions} #{pathspec}") || fail('eslint fail!')
  end
end
