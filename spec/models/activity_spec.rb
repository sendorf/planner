# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'associations' do
    it { should have_many(:opening_hours).class_name('OpeningHour') }
  end

  let(:longitude) { '-34.3432' }
  let(:latitude) { '-35.332' }
  let(:name) { 'Fake Activity' }
  let(:hours_spent) { 1.5 }
  let(:location) { 'outdoors' }
  let(:district) { 'Centro' }
  let(:category) { 'shopping' }
  let(:activity_class) { class_double(described_class) }
  let(:activity) do
    {
      'name' => name,
      'opening_hours' => {
        'mo' => ['10:00-20:00'],
        'tu' => ['10:00-20:00'],
        'we' => ['10:00-20:00'],
        'th' => ['10:00-20:00'],
        'fr' => ['10:00-20:00'],
        'sa' => ['10:00-20:00'],
        'su' => ['10:00-20:00']
      },
      'hours_spent' => hours_spent,
      'category' => category,
      'location' => location,
      'district' => district,
      'latlng' => [40.4173423, -3.7144063]
    }
  end
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
          { 'tu': hours }
        ]
      }
    }.to_json
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

  subject do
    described_class.new(
      longitude: longitude, latitude: latitude, name: name, hours_spent: hours_spent,
      location: location, district: district, category: category
    )
  end

  describe '#recommend' do
    let(:date) { '2020-02-01' }
    let(:start_time) { '08:00' }
    let(:end_time) { '18:00' }
    let(:opening_hour_class) { class_double(OpeningHour) }
    let(:activity_record) { instance_double(described_class, activity_fields) }
    let(:activity_record_1) { instance_double(described_class, activity_fields_1) }
    let(:hours_spent_1) { 3.5 }
    let(:activity_fields) do
      {
        id: 34,
        name: activity['name'],
        hours_spent: activity['hours_spent'],
        category: activity['category'],
        location: activity['location'],
        district: activity['district'],
        longitude: activity['latlng'][1],
        latitude: activity['latlng'][0]
      }
    end
    let(:activity_fields_1) do
      {
        id: 54,
        name: 'Fake',
        hours_spent: hours_spent_1,
        category: 'Categ',
        location: 'in',
        district: 'Dist',
        longitude: '-3.7485',
        latitude: '34.653443'
      }
    end
    let(:opening_hour_record) { instance_double(OpeningHour, opening_hour_fields) }
    let(:opening_hour_record_1) { instance_double(OpeningHour, opening_hour_fields_1) }
    let(:opening_hour_fields) do
      {
        start_time: start_time,
        end_time: end_time,
        wday: 4,
        activity_id: activity_record.id
      }
    end
    let(:opening_hour_fields_1) do
      {
        start_time: start_time,
        end_time: end_time,
        wday: 4,
        activity_id: activity_record_1.id
      }
    end
    let(:filters) do
      {
        start_time: start_time,
        end_time: end_time,
        date: date
      }
    end

    context 'when start_time is nil' do
      let(:filters) { { date: date, end_time: end_time } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when end_time is nil' do
      let(:filters) { { date: date, start_time: start_time } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when date is nil' do
      let(:filters) { { end_time: end_time, start_time: start_time } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when date is incorrect' do
      let(:filters) { { end_time: end_time, start_time: start_time, date: 'vcxsdfa' } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when start_time is incorrect' do
      let(:filters) { { end_time: end_time, start_time: 'dsafsadsa', date: date } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when start_time is incorrect' do
      let(:filters) { { end_time: 'rcsafasfsa', start_time: start_time, date: date } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when start_time and end_time are equal' do
      let(:filters) { { end_time: start_time, start_time: start_time, date: date } }
      it 'returns null' do
        expect(described_class.recommend(filters)).to eq nil
      end
    end

    context 'when start and end time are correctly ordered' do
      context 'when no opening hours matches the filters' do
        let(:opening_hours) { [] }
        it 'returns null' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class.recommend(filters)).to eq nil
        end
      end

      context 'when no activity matches the available activity filter matches the filters' do
        let(:opening_hours) { [opening_hour_record] }
        let(:activity_ids) { [activity_record.id] }
        let(:available_time) { (end_time.to_time - start_time.to_time) / 3600 }
        let(:activities) { [] }

        it 'returns null' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class).to receive(:where).with(id: activity_ids).and_return activity_class
          expect(activity_class).to receive(:available_activity).with(available_time).and_return activities
          expect(described_class.recommend(filters)).to eq nil
        end
      end

      context 'when one opening hour matches the filters' do
        let(:opening_hours) { [opening_hour_record] }
        let(:activity_ids) { [activity_record.id] }
        let(:available_time) { (end_time.to_time - start_time.to_time) / 3600 }
        let(:activities) { [activity_record] }

        it 'returns the activity in geojson format' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class).to receive(:where).with(id: activity_ids).and_return activity_class
          expect(activity_class).to receive(:available_activity).with(available_time).and_return activities
          expect(activity_record).to receive(:to_geojson).and_return activity_geojson
          expect(described_class.recommend(filters)).to eq activity_geojson
        end
      end

      context 'when more than one opening hour matches the filters' do
        let(:opening_hours) { [opening_hour_record, opening_hour_record_1] }
        let(:activity_ids) { [activity_record.id, activity_record_1.id] }
        let(:available_time) { (end_time.to_time - start_time.to_time) / 3600 }
        let(:activities) { [activity_record, activity_record_1] }

        it 'returns the activity with more hours spent in geojson format' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class).to receive(:where).with(id: activity_ids).and_return activity_class
          expect(activity_class).to receive(:available_activity).with(available_time).and_return activities
          expect(activity_record_1).to receive(:to_geojson).and_return activity_geojson
          expect(described_class.recommend(filters)).to eq activity_geojson
        end
      end
    end

    context 'when start and end time are incorrectly ordered' do
      let(:filters) do
        {
          start_time: end_time,
          end_time: start_time,
          date: date
        }
      end
      context 'when no opening hours matches the filters' do
        let(:opening_hours) { [] }
        it 'returns null' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class.recommend(filters)).to eq nil
        end
      end

      context 'when no activity matches the available activity filter matches the filters' do
        let(:opening_hours) { [opening_hour_record] }
        let(:activity_ids) { [activity_record.id] }
        let(:available_time) { (end_time.to_time - start_time.to_time) / 3600 }
        let(:activities) { [] }

        it 'returns null' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class).to receive(:where).with(id: activity_ids).and_return activity_class
          expect(activity_class).to receive(:available_activity).with(available_time).and_return activities
          expect(described_class.recommend(filters)).to eq nil
        end
      end

      context 'when one opening hour matches the filters' do
        let(:opening_hours) { [opening_hour_record] }
        let(:activity_ids) { [activity_record.id] }
        let(:available_time) { (end_time.to_time - start_time.to_time) / 3600 }
        let(:activities) { [activity_record] }

        it 'returns the activity in geojson format' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class).to receive(:where).with(id: activity_ids).and_return activity_class
          expect(activity_class).to receive(:available_activity).with(available_time).and_return activities
          expect(activity_record).to receive(:to_geojson).and_return activity_geojson
          expect(described_class.recommend(filters)).to eq activity_geojson
        end
      end

      context 'when more than one opening hour matches the filters' do
        let(:opening_hours) { [opening_hour_record, opening_hour_record_1] }
        let(:activity_ids) { [activity_record.id, activity_record_1.id] }
        let(:available_time) { (end_time.to_time - start_time.to_time) / 3600 }
        let(:activities) { [activity_record, activity_record_1] }

        it 'returns the activity with more hours spent in geojson format' do
          expect(OpeningHour).to receive(:wday).with(date.to_date.wday).and_return opening_hour_class
          expect(opening_hour_class).to receive(:between_hours).with(start_time, end_time).and_return opening_hours
          expect(described_class).to receive(:where).with(id: activity_ids).and_return activity_class
          expect(activity_class).to receive(:available_activity).with(available_time).and_return activities
          expect(activity_record_1).to receive(:to_geojson).and_return activity_geojson
          expect(described_class.recommend(filters)).to eq activity_geojson
        end
      end
    end
  end

  describe '#filtered_geojson' do
    let(:activities_geojson) do
      "{\"type\": \"FeatureCollection\", \"features\": [#{activities.map(&:to_geojson).join(',')}]}"
    end
    let(:filters) do
      {
        category: category_filter.to_s,
        location: location_filter.to_s,
        district: district_filter.to_s
      }
    end
    let(:activity_record) { instance_double(described_class, activity_fields) }
    let(:activities) { [activity_record] }

    context 'when catagory is nil' do
      let(:category_filter) { nil }

      context 'when location is nil' do
        let(:location_filter) { nil }

        context 'when district is nil' do
          let(:district_filter) { nil }

          it 'returns a geojson with all activities' do
            expect(described_class).to receive(:all).and_return activities
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(described_class).not_to receive(:with_district)
            expect(described_class).not_to receive(:with_location)
            expect(described_class).not_to receive(:with_category)
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end

        context 'when district is not nil' do
          let(:district_filter) { district }

          it 'returns a geojson with activities filtered by district' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(activity_class).to receive(:with_district).with(district_filter).and_return activities
            expect(described_class).not_to receive(:with_location)
            expect(described_class).not_to receive(:with_category)
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end
      end

      context 'when location is not nil' do
        let(:location_filter) { location }

        context 'when district is nil' do
          let(:district_filter) { nil }

          it 'returns a geojson with all activities' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(described_class).not_to receive(:with_district)
            expect(activity_class).to receive(:with_location).with(location_filter).and_return activities
            expect(described_class).not_to receive(:with_category)
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end

        context 'when district is not nil' do
          let(:district_filter) { district }

          it 'returns a geojson with activities filtered by district' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(activity_class).to receive(:with_district).with(district_filter).and_return activities
            expect(activity_class).to receive(:with_location).with(location_filter).and_return activity_class
            expect(described_class).not_to receive(:with_category)
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end
      end
    end

    context 'when catagory is not nil' do
      let(:category_filter) { category }

      context 'when location is nil' do
        let(:location_filter) { nil }

        context 'when district is nil' do
          let(:district_filter) { nil }

          it 'returns a geojson with all activities' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(described_class).not_to receive(:with_district)
            expect(described_class).not_to receive(:with_location)
            expect(activity_class).to receive(:with_category).with(category_filter).and_return activities
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end

        context 'when district is not nil' do
          let(:district_filter) { district }

          it 'returns a geojson with activities filtered by district' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(activity_class).to receive(:with_district).with(district_filter).and_return activities
            expect(described_class).not_to receive(:with_location)
            expect(activity_class).to receive(:with_category).with(category_filter).and_return activity_class
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end
      end

      context 'when location is not nil' do
        let(:location_filter) { location }

        context 'when district is nil' do
          let(:district_filter) { nil }

          it 'returns a geojson with all activities' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(described_class).not_to receive(:with_district)
            expect(activity_class).to receive(:with_location).with(location_filter).and_return activities
            expect(activity_class).to receive(:with_category).with(category_filter).and_return activity_class
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end

        context 'when district is not nil' do
          let(:district_filter) { district }

          it 'returns a geojson with activities filtered by district' do
            expect(described_class).to receive(:all).and_return activity_class
            expect(activity_record).to receive(:to_geojson).and_return(activity_geojson).twice
            expect(activity_class).to receive(:with_district).with(district_filter).and_return activities
            expect(activity_class).to receive(:with_location).with(location_filter).and_return activity_class
            expect(activity_class).to receive(:with_category).with(category_filter).and_return activity_class
            expect(described_class.filtered_geojson(filters)).to eq activities_geojson
          end
        end
      end
    end
  end

  describe '#to_geojson' do
    let(:opening_hours) { [opening_hour] }
    let(:opening_hour) { double('opening_hour', wday: 2, start_time: start_time, end_time: end_time) }

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
