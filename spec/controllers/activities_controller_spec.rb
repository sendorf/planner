# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  let(:activity) do
    {
      'type': 'Feature', 'geometry': { 'type': 'Point', 'coordinates': [-3.7081466, 40.4087357] },
      'properties': { 'name': 'El Rastro', 'hours_spent': 2.5, 'category': 'shopping',
                      'location': 'outdoors', 'district': 'Centro', 'opening_hours': [{ 'su': '09:00-15:00' }] }
    }.to_json
  end

  describe 'GET #available' do
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

  describe 'GET #recommend' do
    let(:activity_1) do
      {
        'type': 'Feature', 'geometry': { 'type': 'Point', 'coordinates': [-3.7081466, 40.4087357] },
        'properties': { 'name': 'El Rastro', 'hours_spent': 2.5, 'category': 'shopping',
                        'location': 'outdoors', 'district': 'Centro', 'opening_hours': [{ 'su': '09:00-15:00' }] }
      }.to_json
    end
    let(:filters) do
      {
        date: date,
        end_time: end_time,
        start_time: start_time
      }
    end
    let(:date) { '2020-02-01' }
    let(:end_time) { '17:00' }
    let(:start_time) { '09-00' }

    context 'when start_time is nil' do
      let(:filters) { { date: date, end_time: end_time } }
      it 'returns null' do
        get :recommend, params: filters
        expect(response.body).to eq 'null'
      end
    end

    context 'when end_time is nil' do
      let(:filters) { { date: date, start_time: start_time } }
      it 'returns null' do
        get :recommend, params: filters
        expect(response.body).to eq 'null'
      end
    end

    context 'when date is nil' do
      let(:filters) { { end_time: end_time, start_time: start_time } }
      it 'returns null' do
        get :recommend, params: filters
        expect(response.body).to eq 'null'
      end
    end

    context 'when the filter doesn\'t return an activity' do
      it 'returns null' do
        expect(Activity).to receive(:recommend).with(filters).and_return nil
        get :recommend, params: filters
        expect(response.body).to eq 'null'
      end
    end

    context 'when the filter doesn\'t return an activity' do
      it 'returns null' do
        expect(Activity).to receive(:recommend).with(filters).and_return activity_1
        get :recommend, params: filters
        expect(response.body).to eq activity_1
      end
    end
  end
end
