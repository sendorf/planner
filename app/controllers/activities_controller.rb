# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def available
    render json: Activity.filtered_geojson
  end
end
