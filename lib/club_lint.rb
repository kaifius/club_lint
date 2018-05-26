require_relative 'club_lint/configuration'

module ClubLint
  def self.config
    @config ||= ClubLint::Configuration.new
  end

  def clubhouse
    @clubhouse ||= ClubhouseRuby::Clubhouse.new(ClubLint.config.clubhouse_api_token)
  end
end
