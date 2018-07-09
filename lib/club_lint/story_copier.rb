module ClubLint

  class StoryCopier

    def call(story_id, overwrite_attrs: {})
      existing_story_attrs = symbolize_keys(clubhouse.stories(story_id).list[:content])
      attrs_to_copy = slice(
        existing_story_attrs,
        [
          :name,
          :story_type,
          :estimate,
          :project_id,
          :labels,
          :requested_by_id,
          :owner_ids,
          :follower_ids,
          :epic_id,
          :description,
        ],
      )
      new_story_attrs = attrs_to_copy.merge(symbolize_keys(overwrite_attrs)).compact
      story = symbolize_keys(clubhouse.stories.create(new_story_attrs))[:content]

      story_tasks = existing_story_attrs[:tasks].map do |task|
        clubhouse.stories(story[:id]).tasks.create(
          { description: symbolize_keys(task)[:description] }
        )
      end
    end

  end

end
