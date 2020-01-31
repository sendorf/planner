# frozen_string_literal: true

class ActivitiesController < ApplicationController
  def available
    filter_params = {
      category: available_activities_params[:category],
      location: available_activities_params[:location],
      district: available_activities_params[:district]
    }
    render json: Activity.filtered_geojson(filter_params)
  end

  private

  def available_activities_params
    params.permit(:category, :location, :district)
  end
end
