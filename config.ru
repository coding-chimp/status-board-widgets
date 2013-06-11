require 'rubygems'
require 'bundler'

Bundler.require

require './app'
Dir.glob("./app/controllers/*.rb").each { |c| require c }

map "/vigil" do
  run VigilController
end

map "/subscribers" do
  run SubscribersController
end

map "/traffic" do
  run TrafficController
end

map "/github" do
  run GithubController
end

map "/" do
  run StatusBoardWidgets
end