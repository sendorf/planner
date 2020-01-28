module ActivitiesLoader
  class File
    def initialize(file_path)
      @file_path = file_path
    end

    def load
      activities_json = read_json
      ::Activity.bulk_create_from_json(activities_json)
    end

    private

    def read_json
      file = ::File.read(@file_path)
      JSON.parse(file)
    end
  end
end