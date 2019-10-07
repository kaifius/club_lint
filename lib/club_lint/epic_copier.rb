module ClubLint

  class EpicCopier

    def call(epic_id, overwrite_attrs: {}, story_ids: [], story_overwrite_attrs: {})
      existing_epic_attrs = symbolize_keys(clubhouse.epics(epic_id).list[:content])
      attrs_to_copy = slice(
        existing_epic_attrs,
        [
          :name,
          :description,
          :labels,
          :follower_ids,
          :requested_by_id,
          :owner_ids,
          :milestone_id,
        ],
      )
      new_epic_attrs = attrs_to_copy.merge(symbolize_keys(overwrite_attrs)).compact

      new_epic = symbolize_keys(clubhouse.epics.create(new_epic_attrs)[:content])
      unless story_ids.empty?
        story_attrs = symbolize_keys(story_overwrite_attrs).merge(epic_id: new_epic[:id])

        story_ids.each do |story_id|
          StoryCopier.new.call(story_id, overwrite_attrs: story_attrs)
        end
      end
    end

  end

end
