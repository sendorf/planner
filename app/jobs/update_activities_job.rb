class UpdateActivitiesJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    ActivitiesLoader::File.new(file_path).load
  end
end
