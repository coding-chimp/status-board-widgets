require "sinatra/activerecord/rake"
require "rubygems"
require "bundler"
Bundler.require

require "./app"
require_relative "./tasks/fetch_contributions"

desc "Fetch todays commits."
task :fetch_today do
  FetchContributions.new.fetch_today
end

desc "Fetch contribution history."
task :fetch_history do
  FetchContributions.new.fetch_history
end
