# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateActivitiesJob, type: :job do
  let(:activities_json_path) { 'activities/json/path' }

  describe '#perform_later' do
    it 'loads the activities JSON' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        UpdateActivitiesJob.perform_later(activities_json_path)
      end.to have_enqueued_job.with(activities_json_path)
    end
  end

  describe '#perform' do
    let(:activities_loader) { double('activities_loader') }

    it 'calls activities loader file load' do
      expect(ActivitiesLoader::File).to receive(:new).with(activities_json_path).and_return activities_loader
      expect(activities_loader).to receive(:load)
      subject.perform(activities_json_path)
    end
  end
end
