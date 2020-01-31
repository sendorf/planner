# frozen_string_literal: true

namespace :db do
  desc 'Populates the DB with the data from the file passed as a parameter'
  task :populate, [:json_path] => :environment do |_, args|
    json_path = args.fetch(:json_path, 'activities_jsons/madrid.json')

    puts "############# STARTING: Populating the db with #{json_path} #############"
    UpdateActivitiesJob.perform_later(json_path)
    puts "############# FINISHED: Populating the db with #{json_path} #############"
  end
end
