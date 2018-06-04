require 'yaml'
require 'erb'

module ClubLint
  # `ClubLint::Configuration` loads in the configuration from the
  # `.club_lint.yml` file in the current directory, and merges it into the
  # default configurations. A project must have at minimum a configuration file
  # with key `clubhouse_api_token`
  class Configuration

    REQUIRED_CONFIG_KEYS = [:clubhouse_api_token].freeze

    OPTIONAL_CONFIG_KEYS = [
      :engineering_team_emails,
      :chore_stories,
      :sprintly_tasks,
    ].freeze

    CONFIGURATION_KEYS =
      (OPTIONAL_CONFIG_KEYS + REQUIRED_CONFIG_KEYS).freeze

    attr_accessor(*CONFIGURATION_KEYS)

    def initialize
      options = yaml_config

      CONFIGURATION_KEYS.each do |key|
        public_send("#{key}=", options.fetch(key))
        options.delete(key)
      end
      raise "invalid options: #{options.keys}" if options.any?
    end

    def yaml_config
      return @yaml_config if @yaml_config
      unless File.exist?(config_file_path)
        abort('Please add a ".club_lint.yml" file and try again')
      end
      @yaml_config = symbolize_keys(YAML.safe_load(config_file_contents))
    end
  private

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
