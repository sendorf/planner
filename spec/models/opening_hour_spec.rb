# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpeningHour, type: :model do
  describe 'associations' do
    it { should belong_to(:activity).class_name('Activity') }
  end

  let(:start_time) { '08:00' }
  let(:end_time) { '18:00' }
  let(:activity_id) { 23_563 }
  let(:wday) { 3 }

  subject do
    described_class.new(
      start_time: start_time, end_time: end_time, activity_id: activity_id, wday: wday
    )
  end

  describe '#hours' do
    it 'returns the hours with the correct format' do
      expect(subject.hours).to eq "#{start_time}-#{end_time}"
    end
  end

  describe '#bulk_create' do
    let(:activity) { double('activity') }

    context 'when open hours is nil' do
      let(:opening_hours) { nil }

      it 'returns nil' do
        expect(described_class.bulk_create(opening_hours, activity)).to be_nil
      end

      context 'when activity is nil' do
        let(:activity) { nil }

        it 'returns nil' do
          expect(described_class.bulk_create(opening_hours, activity)).to be_nil
        end
      end
    end

    context 'when open hours is an empty collection' do
      let(:opening_hours) { [] }

      it 'returns nil' do
        expect(described_class.bulk_create(opening_hours, activity)).to be_nil
      end

      context 'when activity is nil' do
        let(:activity) { nil }

        it 'returns nil' do
          expect(described_class.bulk_create(opening_hours, activity)).to be_nil
        end
      end
    end

    context 'when activities is a collection' do
      let(:opening_hours) { [opening_hour] }

      context 'when it has a correct element' do
        let(:opening_hour) { ['mo', ["#{start_time}-#{end_time}"]] }
        let(:start_time) { '10:00' }
        let(:end_time) { '20:00' }
        let(:opening_hours_fields) do
          {
            wday: %w[su mo tu we th fr sa].index(opening_hour[0]),
            start_time: start_time,
            end_time: end_time,
            activity: activity
          }
        end

        context 'when activity is nil' do
          let(:activity) { nil }

          it 'returns nil' do
            expect(described_class.bulk_create(opening_hours, activity)).to be_nil
          end
        end

        context 'when find/create is called with the correct params' do
          it 'returns activities' do
            expect(described_class).to receive(:find_or_create_by).with(opening_hours_fields)
            described_class.bulk_create(opening_hours, activity)
          end
        end
      end

      context 'with it\'s element as nil' do
        let(:opening_hour) { nil }

        it 'returns opening_hours' do
          expect(described_class).not_to receive(:find_or_create_by)
          expect(described_class.bulk_create(opening_hours, activity)).to eq opening_hours
        end
      end
    end
  end
end
