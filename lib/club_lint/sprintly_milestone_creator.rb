module ClubLint

  class SprintlyMilestoneCreator
    attr_reader :sprint_start, :sprint_end, :date_string, :milestone_id

    def self.call(sprint_week: 1, sprint_start_override: nil)
      new(
        sprint_week: sprint_week,
        sprint_start_override: sprint_start_override,
      ).call
    end

    def initialize(sprint_week: 1, sprint_start_override: nil)
      @sprint_start = sprint_start_override || this_sprint_start(sprint_week)
      @sprint_end = sprint_start + 11
      @date_string = sprint_date_string(sprint_start, sprint_end)
    end

    def call
      milestone_id = create_milestone[:content]['id']
      epics = create_epics(milestone_id)

      chores_epic_id = find_chores_epic(epics)[:content]['id']
      create_chores_stories(chores_epic_id)
    end

  private

    def create_milestone
      milestone = clubhouse.milestones.create(
        name: "Sprintly Tasks [#{date_string}]",
        state: 'in progress',
        description: config.sprintly_milestone_description,
        started_at_override: sprint_start,
        completed_at_override: sprint_end,
      )
      milestone

    end

    def create_epics(milestone_id)
      config.sprintly_epics.map do |epic|
        epic = clubhouse.epics.create(
          name: "#{epic['name']} [#{date_string}]",
          state: 'in progress',
          deadline: sprint_end,
          milestone_id: milestone_id,
          description: epic['description'],
        )
      end
    end

    def create_chores_stories(chores_epic_id)
      eng_emails = config.engineering_team_emails.dup
      config.chore_stories.each do |chore|
        assignee_email = if eng_emails.empty?
                     config.engineering_team_emails.sample
                   else
                     eng_emails.delete(eng_emails.sample)
                   end

        story = clubhouse.stories.create(
          name: "#{chore['name']} [#{date_string}]",
          deadline: sprint_end,
          epic_id: chores_epic_id,
          project_id: config.project_id,
          story_type: 'chore',
          description: chore['description'],
          estimate: 1,
          owner_ids: [team_email_to_uuid_map[assignee_email]],
          labels: [{ name: 'chores' }]
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

    def find_chores_epic(epics_list)
      epics_list.detect { |epic| epic[:content]['name'].match(/Chores/) }
    end

  end

end
