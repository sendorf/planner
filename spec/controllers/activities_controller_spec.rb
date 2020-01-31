require 'rails_helper'

RSpec.describe ActivitiesController, type: :controller do
  describe 'GET available' do
    it 'renders the index template' do
      get :available
      expect(response.body).to eq 'true'
    end
  end
end
