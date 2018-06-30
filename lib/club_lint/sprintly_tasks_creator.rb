module ClubLint

  class SprintlyTasksCreator

    SPRINTLY_MILESTONE_DESCRIPTION =
      "Recurring tasks and projects for the current sprint:\n" \
      "  - Retrospective: At the beginning of each sprint we'll create a story in "\
      " the `doing` column and assign to everyone.\n\n".freeze\

    'At the beginning of each sprint, a new epic should be created for each of '\
    'the below with the dates of the sprint. For example '\
    '`Chores 5/7/18 - 5/18/18`. Cards will be created for each of the chores '\
    'and assigned at random. The person on support should not be assigned a '\
    'chore for the week. \n"'\
    "  - Fillers\n"\
    "  - Chores\n"\
    "  - Errors\n"\
    '  - Bugs'.freeze

    CHORES_DUE_WK_1 = ['Update Gems Wk 1', 'Update NPM Wk 1'].freeze
    CHORES_DUE_WK_2 = [
      'Performance Enhancement(s)',
      'Update Code Coverage',
      'Update Gems Wk 2',
      'Update NPM Wk 2',
    ].freeze

    PROJECT_ID = 26

    attr_reader :sprint_start, :sprint_end, :date_string

    def self.call
      self.new.call
    end

    def initialize(sprint_week: 1, sprint_start_override: nil)
      @sprint_start = sprint_start_override || this_sprint_start(sprint_week)
      @sprint_end = sprint_start + 11
      @date_string = sprint_date_string(sprint_start, sprint_end)
    end

    def call
      create_epics(create_milestone[:content]['id'])
    end

    def create_milestone
      clubhouse.milestones.create(
        name: "Sprintly Tasks #{date_string}",
        state: 'in progress',
        description: SPRINTLY_MILESTONE_DESCRIPTION,
        started_at_override: sprint_start,
        completed_at_override: sprint_end,
      )
    end

    # def create_chores_epic(milestone_id)
    #   clubhouse.epics.create(
    #     name: "Chores #{sprint_date_string(sprint_start, sprint_end)}",
    #     deadline: sprint_end,
    #     milestone_id: milestone_id,
    #     # follower_ids: engineering_team_ids,
    #     # owner_ids: engineering_team_ids,
    #   )
    # end

    def create_epics(milestone_id)
      ClubLint.config.sprintly_tasks.each do |task|
        clubhouse.epics.create(
          name: "#{task} #{date_string}",
          state: 'in progress',
          deadline: sprint_end,
          milestone_id: milestone_id,
        )
      end
      # chores_epic = create_chores_epic(milestone_id)
      # create_chores_stories(chores_epic[:content]['id'])
    end

    def create_chores_stories(chores_epic_id)
      ClubLint.config.chore_stories.each do |chore|
        clubhouse.stories.create(
          name: "#{chore} #{date_string}",
          deadline: sprint_end,
          epic_id: chores_epic_id,
          project_id: PROJECT_ID,
        )
      end
    end

    def this_sprint_start(sprint_week)
      today = Date.today
      days_since_sprint_start = sprint_week == 1 ? today.wday - 1 : today.wday + 6
      today - days_since_sprint_start
    end

    def sprint_date_string(start_date, end_date)
      "#{start_date.strftime('%m.%d')} - #{end_date.strftime('%m.%d')}"
    end

  end

end
