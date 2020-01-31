# frozen_string_literal: true

class Activity < ApplicationRecord
  has_many :opening_hours

  scope :with_category, ->(category) { where("category like '%#{category}%'") }
  scope :with_location, ->(location) { where("location like '%#{location}%'") }
  scope :with_district, ->(district) { where("district like '%#{district}%'") }

  def self.filtered_geojson(category: nil, location: nil, district: nil)
    activities = Activity.all
    activities.with_category(category) if category
    activities.with_location(location) if location
    activities.with_district(district) if district
    "{\"type\": \"FeatureCollection\", \"features\": [#{activities.map(&:to_geojson).join(',')}]}"
  end

  def to_geojson
    {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [longitude.to_f, latitude.to_f]
      },
      'properties': {
        'name': name,
        'hours_spent': hours_spent,
        'category': category,
        'location': location,
        'district': district,
        'opening_hours': opening_hours_geojson
      }
    }.to_json
  end

  def self.bulk_create(activities)
    return if activities.blank?

    activities.each do |activity_hash|
      next if activity_hash.blank?

      activity = find_or_create_by(
        extract_activity_fields(activity_hash)
      )
      OpeningHour.bulk_create(activity_hash['opening_hours'], activity)
    end
  end

  private

  def opening_hours_geojson
    opening_hours_array = []
    opening_hours.each do |opening_hour|
      opening_hours_array << { %w[su mo tu we th fr sa][opening_hour.wday] => opening_hour.hours }
    end
    opening_hours_array
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
