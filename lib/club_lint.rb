require_relative 'club_lint/configuration'
require_relative 'club_lint/sprintly_tasks_creator.rb'

module ClubLint
  def self.config
    @config ||= ClubLint::Configuration.new
  end

  def clubhouse
    ClubhouseRuby::Clubhouse.new(ClubLint.config.clubhouse_api_token)
  end

  def state_to_id_map
    @state_to_id_map if @state_to_id_map

    workflow = clubhouse.workflows.list[:content].detect do |workflow|
      workflow['name'] == 'Default'
    end

    workflow['states'].map { |state| { state['name'] => state['id'] } }
  end

end
