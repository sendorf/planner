class Activity < ApplicationRecord
  has_many :open_times

  def self.bulk_create_from_json(activities_json)
    activities_json.each do |activity_json|
      next if activities_json.blank?
      activity = find_or_create_by(
        name: activity_json['name'],
        hours_spent: activity_json['hours_spent'],
        category: activity_json['category'],
        location: activity_json['location'],
        district: activity_json['district'],
        longitude: activity_json['latlng'][1],
        latitude: activity_json['latlng'][0],
      )
      OpenTime.bulk_create_from_json(activity_json['opening_hours'], activity)
    end
  end
end
