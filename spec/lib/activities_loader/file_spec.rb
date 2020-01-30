# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesLoader::File do
  let(:file_path) { 'fake/path' }

  subject { described_class.new(file_path) }

  describe '#load' do
    let(:activities_json) { '[{"foo": "bar"}]' }
    let(:activities) { [{ 'foo' => 'bar' }] }

    it 'create activities from JSON file' do
      expect(::File).to receive(:read).with(file_path).and_return activities_json
      expect(Activity).to receive(:bulk_create).with(activities)
      subject.load
    end
  end
end
