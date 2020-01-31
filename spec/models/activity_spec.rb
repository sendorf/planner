# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'associations' do
    it { should have_many(:opening_hours).class_name('OpeningHour') }
  end

  let(:longitude) { '-34.3432' }
  let(:latitude) { '-35.332' }
  let(:name) { 'Fake Activity' }
  let(:hours_spent) { 3.5 }
  let(:location) { 'outdoors' }
  let(:district) { 'Centro' }
  let(:category) { 'shopping' }

  subject do
    described_class.new(
      longitude: longitude, latitude: latitude, name: name, hours_spent: hours_spent,
      location: location, district: district, category: category
    )
  end

  describe 'to_geojson' do
    let(:opening_hours) { [opening_hour] }
    let(:opening_hour) { double('opening_hour', wday: 2, start_time: start_time, end_time: end_time) }
    let(:start_time) { '08:00' }
    let(:end_time) { '18:00' }
    let(:hours) { "#{start_time}-#{end_time}" }
    let(:activity_geojson) do
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
          'opening_hours': [
            { 'tu': [hours] }
          ]
        }
      }.to_json
    end

    it 'returns the subject as a geojson object' do
      expect(subject).to receive(:opening_hours).and_return opening_hours
      expect(opening_hour).to receive(:hours).and_return hours
      expect(subject.to_geojson).to eq activity_geojson
    end
  end

  describe '#bulk_create' do
    context 'when activities is nil' do
      let(:activities) { nil }

      it 'returns nil' do
        expect(described_class.bulk_create(activities)).to be_nil
      end
    end

    context 'when activities is an empty collection' do
      let(:activities) { [] }

      it 'returns nil' do
        expect(described_class.bulk_create(activities)).to be_nil
      end
    end

    context 'when activities is a collection' do
      let(:activities) { [activity] }

      context 'when it has a correct element' do
        let(:activity) do
          {
            'name' => 'Palacio Real',
            'opening_hours' => {
              'mo' => ['10:00-20:00'],
              'tu' => ['10:00-20:00'],
              'we' => ['10:00-20:00'],
              'th' => ['10:00-20:00'],
              'fr' => ['10:00-20:00'],
              'sa' => ['10:00-20:00'],
              'su' => ['10:00-20:00']
            },
            'hours_spent' => 1.5,
            'category' => 'cultural',
            'location' => 'outdoors',
            'district' => 'Centro',
            'latlng' => [40.4173423, -3.7144063]
          }
        end
        let(:activity_fields) do
          {
            name: activity['name'],
            hours_spent: activity['hours_spent'],
            category: activity['category'],
            location: activity['location'],
            district: activity['district'],
            longitude: activity['latlng'][1],
            latitude: activity['latlng'][0]
          }
        end

        context 'when find/create returns an activity' do
          let(:activity_record) { double('activity') }

          it 'returns activities' do
            expect(described_class).to receive(:find_or_create_by).with(activity_fields)
                                                                  .and_return activity_record
            expect(OpeningHour).to receive(:bulk_create).with(activity['opening_hours'], activity_record)
            expect(described_class.bulk_create(activities)).to eq activities
          end
        end

        context 'when find/create returns nil' do
          let(:activity_record) { nil }

          it 'returns activities' do
            expect(described_class).to receive(:find_or_create_by).with(activity_fields)
                                                                  .and_return activity_record
            expect(OpeningHour).to receive(:bulk_create).with(activity['opening_hours'], activity_record)
            expect(described_class.bulk_create(activities)).to eq activities
          end
        end
      end

      context 'with it\'s element as nil' do
        let(:activity) { nil }

        it 'returns activities' do
          expect(described_class).not_to receive(:find_or_create_by)
          expect(OpeningHour).not_to receive(:bulk_create)
          expect(described_class.bulk_create(activities)).to eq activities
        end
      end
    end
  end
end
