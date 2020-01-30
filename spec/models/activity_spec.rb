# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'associations' do
    it { should have_many(:open_times).class_name('OpenTime') }
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
            expect(OpenTime).to receive(:bulk_create).with(activity['opening_hours'], activity_record)
            expect(described_class.bulk_create(activities)).to eq activities
          end
        end

        context 'when find/create returns nil' do
          let(:activity_record) { nil }

          it 'returns activities' do
            expect(described_class).to receive(:find_or_create_by).with(activity_fields)
                                                                  .and_return activity_record
            expect(OpenTime).to receive(:bulk_create).with(activity['opening_hours'], activity_record)
            expect(described_class.bulk_create(activities)).to eq activities
          end
        end
      end

      context 'with it\'s element as nil' do
        let(:activity) { nil }

        it 'returns activities' do
          expect(described_class).not_to receive(:find_or_create_by)
          expect(OpenTime).not_to receive(:bulk_create)
          expect(described_class.bulk_create(activities)).to eq activities
        end
      end
    end
  end
end
