require_relative 'club_lint/configuration'
require_relative 'club_lint/sprintly_milestone_creator.rb'
require 'clubhouse_ruby'

module ClubLint

  def config
    @config ||= ClubLint::Configuration.new
  end

  def clubhouse
    # use a new instance every time to avoid inconsistency with chaining
    ClubhouseRuby::Clubhouse.new(ClubLint.config.clubhouse_api_token)
  end

  def team_email_to_uuid_map
    @team_email_to_uuid_map ||= clubhouse.members.list[:content].map do |member|
      [member['profile']['email_address'], member['id']]
    end.to_h
  end

  def delete_milestone(milestone_id)
    epic_ids_to_delete = clubhouse.epics.list[:content].map do |epic|
      epic['milestone_id'] if epic['milestone_id'] == milestone_id
    end.compact

    epic_ids_to_delete.each { |epic_id| clubhouse.epics(epic_id).delete }
    clubhouse.milestones(milestone_id).delete
  end

end
