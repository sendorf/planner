# frozen_string_literal: true

class Activity < ApplicationRecord
  has_many :opening_hours

  scope :with_category, ->(category) { where("category ilike '%#{category}%'") }
  scope :with_location, ->(location) { where("location ilike '%#{location}%'") }
  scope :with_district, ->(district) { where("district ilike '%#{district}%'") }
  scope :indoors, -> { where(location: 'indoors') }
  scope :available_activity, ->(available_time) { where("hours_spent <= #{available_time}") }

  def self.recommend(start_time: nil, end_time: nil, date: nil)
    return if wrong_recomendation_params(start_time, end_time, date)

    start_time, end_time = time_order(start_time, end_time)

    activity = obtain_recommendation(start_time, end_time, date)

    return if activity.blank?

    activity.to_geojson
  end

  def self.filtered_geojson(category: nil, location: nil, district: nil)
    activities = Activity.all
    activities = activities.with_category(category) if category.present?
    activities = activities.with_location(location) if location.present?
    activities = activities.with_district(district) if district.present?

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

  def self.available_time(start_time, end_time)
    (end_time.to_time - start_time.to_time) / 3600
  end

  def self.wrong_recomendation_params(start_time, end_time, date)
    start_time.to_time.blank? || end_time.to_time.blank? || date.to_date.blank? || start_time == end_time
  rescue ArgumentError
    true
  rescue NoMethodError
    true
  end

  def self.obtain_recommendation(start_time, end_time, date)
    available_time = available_time(start_time, end_time)
    filtered_opening_hours = OpeningHour.wday(date.to_date.wday).between_hours(start_time, end_time)
    activity_ids = filtered_opening_hours.flat_map(&:activity_id).uniq
    where(id: activity_ids).available_activity(available_time).max_by(&:hours_spent)
  end

  def self.time_order(start_time, end_time)
    if start_time >= end_time
      aux = end_time
      end_time = start_time
      start_time = aux
    end
    [start_time, end_time]
  end

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
  private_class_method :wrong_recomendation_params
  private_class_method :available_time
  private_class_method :time_order
  private_class_method :obtain_recommendation
end
