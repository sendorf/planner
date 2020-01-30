# frozen_string_literal: true

class Activity < ApplicationRecord
  has_many :open_times

  def self.bulk_create(activities)
    return if activities.blank?

    activities.each do |activity_hash|
      next if activity_hash.blank?

      activity = find_or_create_by(
        extract_activity_fields(activity_hash)
      )
      OpenTime.bulk_create(activity_hash['opening_hours'], activity)
    end
  end

  def self.extract_activity_fields(activity_hash)
    {
      name: activity_hash['name'],
      hours_spent: activity_hash['hours_spent'],
      category: activity_hash['category'],
      location: activity_hash['location'],
      district: activity_hash['district'],
      longitude: activity_hash['latlng'][1],
      latitude: activity_hash['latlng'][0]
    }
  end

  private_class_method :extract_activity_fields
end
