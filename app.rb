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

class StatusBoardWidgets < Sinatra::Base
  configure do
    enable :logging
    set :database_file, "config/database.yml"
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
