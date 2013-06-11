require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/contrib/all'
require 'multi_json'
require 'open-uri'
require 'titleize'
require 'date'
require 'nokogiri'
require 'octokit'

require_relative "app/models/contribution"

class StatusBoardWidgets < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"
    set :views, "app/views"
    set :public_dir, "app/public"
    set :root, File.dirname(__FILE__)

    register Sinatra::ActiveRecordExtension
    register Sinatra::Contrib
  end
  
  # Root
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end

require_relative "app/controllers/github_controller"
require_relative "app/controllers/subscribers_controller"
require_relative "app/controllers/traffic_controller"
require_relative "app/controllers/vigil_controller"