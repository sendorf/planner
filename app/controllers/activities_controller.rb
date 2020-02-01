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

  def recommend
    filter_params = {
      start_time: recommend_params[:start_time],
      end_time: recommend_params[:end_time],
      date: recommend_params[:date]
    }
    render json: Activity.recommend(filter_params)
  end

  private

  def available_activities_params
    params.permit(:category, :location, :district)
  end

  def recommend_params
    params.permit(:start_time, :end_time, :date)
  end
end
