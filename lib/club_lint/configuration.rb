require 'yaml'
require 'erb'

module ClubLint
  # `ClubLint::Configuration` loads in the configuration from the
  # `.club_lint.yml` file in the current directory, and merges it into the
  # default configurations. A project must have at minimum a configuration file
  # with key `clubhouse_api_token`
  class Configuration

    DEFAULT_CONFIGURATION = {}.freeze

    REQUIRED_CONFIGURATION_KEYS = [:clubhouse_api_token].freeze

    CONFIGURATION_KEYS =
      (DEFAULT_CONFIGURATION.keys + REQUIRED_CONFIGURATION_KEYS).freeze

    attr_accessor(*CONFIGURATION_KEYS)

    def initialize
      options = DEFAULT_CONFIGURATION.merge(load_yaml_config)

      CONFIGURATION_KEYS.each do |key|
        public_send("#{key}=", options.fetch(key))
        options.delete(key)
      end
      raise "invalid options: #{options.keys}" if options.any?
    end

  private

    def load_yaml_config
      unless File.exist?(config_file_path)
        abort('Please add a ".club_lint.yml" file and try again')
      end
      symbolize_keys(YAML.safe_load(config_file_contents))
    end

    def config_file_contents
      ERB.new(IO.read(config_file_path)).result
    end

    def config_file_path
      './.club_lint.yml'
    end

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value
        result[new_key] = new_value
      end
    end

  end
end
