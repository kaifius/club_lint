require_relative 'club_lint/configuration'
require_relative 'club_lint/sprintly_tasks_creator.rb'
require 'clubhouse_ruby'

module ClubLint

  def self.config
    @config ||= ClubLint::Configuration.new
  end

  def clubhouse
    @clubhouse ||= ClubhouseRuby::Clubhouse.new(ClubLint.config.clubhouse_api_token)
  end

  def team_email_to_uuid_map
    @team_email_to_uuid_map ||= clubhouse.members.list[:content].map do |member|
      [member['profile']['email_address'], member['id']]
    end.to_h
  end

end
