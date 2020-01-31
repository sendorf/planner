# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  describe 'GET available' do
    let(:activity) do
      {
        'type': 'Feature', 'geometry': { 'type': 'Point', 'coordinates': [-3.7081466, 40.4087357] },
        'properties': { 'name': 'El Rastro', 'hours_spent': 2.5, 'category': 'shopping',
                        'location': 'outdoors', 'district': 'Centro', 'opening_hours': [{ 'su': '09:00-15:00' }] }
      }.to_json
    end
    let(:filters) do
      {
        category: category.to_s,
        location: location.to_s,
        district: district.to_s
      }
    end
    let(:category) { nil }
    let(:location) { nil }
    let(:district) { nil }

    context 'when the filter returns an activity' do
      let(:available_response) do
        "{\"type\": \"FeatureCollection\", \"features\": [#{activity}]}"
      end

      it 'returns the collection with elements' do
        expect(Activity).to receive(:filtered_geojson).with(filters).and_return available_response
        get :available, params: filters
        expect(response.body).to eq available_response
      end
    end

    context 'when the filter doesn\'t return an activity' do
      let(:activity) { nil }
      let(:available_response) do
        "{\"type\": \"FeatureCollection\", \"features\": [#{activity}]}"
      end

      it 'returns the collection with elements' do
        expect(Activity).to receive(:filtered_geojson).with(filters).and_return available_response
        get :available, params: filters
        expect(response.body).to eq available_response
      end
    end
  end
end
