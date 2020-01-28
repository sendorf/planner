class OpenTime < ApplicationRecord
  belongs_to :activity

  def self.bulk_create_from_json(open_hours_json, activity)
    return if activity.blank?

    open_hours_json.each do |key, value|
      next if value.blank?

      times = value.split('-')

      activity.open_times.find_or_create_by(
        wday: %w(su mo tu we th fr sa).index(key),
        start_time: times[0],
        end_time: times[1],
      )
    end
  end
end
