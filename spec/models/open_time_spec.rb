# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenTime, type: :model do
  describe 'associations' do
    it { should belong_to(:activity).class_name('Activity') }
  end

  describe '#bulk_create' do
    let(:activity) { double('activity') }

    context 'when open hours is nil' do
      let(:open_hours) { nil }

      it 'returns nil' do
        expect(described_class.bulk_create(open_hours, activity)).to be_nil
      end

      context 'when activity is nil' do
        let(:activity) { nil }

        it 'returns nil' do
          expect(described_class.bulk_create(open_hours, activity)).to be_nil
        end
      end
    end

    context 'when open hours is an empty collection' do
      let(:open_hours) { [] }

      it 'returns nil' do
        expect(described_class.bulk_create(open_hours, activity)).to be_nil
      end

      context 'when activity is nil' do
        let(:activity) { nil }

        it 'returns nil' do
          expect(described_class.bulk_create(open_hours, activity)).to be_nil
        end
      end
    end

    context 'when activities is a collection' do
      let(:open_hours) { [open_hour] }

      context 'when it has a correct element' do
        let(:open_hour) { ['mo', ["#{start_time}-#{end_time}"]] }
        let(:start_time) { '10:00' }
        let(:end_time) { '20:00' }
        let(:open_hour_fields) do
          {
            wday: %w[su mo tu we th fr sa].index(open_hour[0]),
            start_time: start_time,
            end_time: end_time,
            activity: activity
          }
        end

        context 'when activity is nil' do
          let(:activity) { nil }

          it 'returns nil' do
            expect(described_class.bulk_create(open_hours, activity)).to be_nil
          end
        end

        context 'when find/create is called with the correct params' do
          let(:activity_record) { double('activity') }

          it 'returns activities' do
            expect(described_class).to receive(:find_or_create_by).with(open_hour_fields)
            described_class.bulk_create(open_hours, activity)
          end
        end
      end

      context 'with it\'s element as nil' do
        let(:open_hour) { nil }

        it 'returns open_hours' do
          expect(described_class).not_to receive(:find_or_create_by)
          expect(described_class.bulk_create(open_hours, activity)).to eq open_hours
        end
      end
    end
  end
end
