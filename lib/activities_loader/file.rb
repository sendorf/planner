# frozen_string_literal: true

module ActivitiesLoader
  class File
    def initialize(file_path)
      @file_path = file_path
    end

    def load
      activities = read_json
      ::Activity.bulk_create(activities)
    end

    private

    def read_json
      file = ::File.read(@file_path)
      JSON.parse(file)
    end
  end
end
