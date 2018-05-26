require_relative 'club_lint/configuration'

module ClubLint
  def self.config
    @config ||= ClubLint::Configuration.new
  end

  def clubhouse
    ClubhouseRuby::Clubhouse.new(ClubLint.config.clubhouse_api_token)
  end

  def create_sprintly_milestone(sprint_week: 1, sprint_start_override: nil)
    sprint_start = sprint_start_override || this_sprint_start(sprint_week)
    sprint_end = sprint_start + 11
    date_string = sprint_date_string(sprint_start, sprint_end)
    clubhouse.milestones.create(
      name: "Sprintly Tasks #{date_string}",
      state: 'in progress',
      description: sprintly_milestone_description,
      started_at_override: sprint_start,
      completed_at_override: sprint_end,
    )
  end

  def this_sprint_start(sprint_week)
    today = Date.today
    days_since_sprint_start = sprint_week == 1 ? today.wday - 1 : today.wday + 6
    today - days_since_sprint_start
  end

  def sprint_date_string(start_date, end_date)
    "#{start_date.strftime('%m.%d')} - #{end_date.strftime('%m.%d')}"
  end

  def sprintly_milestone_description
    description = "Recurring tasks and projects for the current sprint:\n" \
      "  - Retrospective: At the beginning of each sprint we'll create a story in "\
      " the `doing` column and assign to everyone.\n\n"\

      "At the beginning of each sprint, a new epic should be created for each of "\
      "the below with the dates of the sprint. For example "\
      "`Chores 5/7/18 - 5/18/18`. Cards will be created for each of the chores " \
      "and assigned at random. The person on support should not be assigned a " \
      "chore for the week. \n" \
      "  - Fillers\n" \
      "  - Chores\n" \
      "  - Errors\n"\
      "  - Bugs\n"
  end

end
