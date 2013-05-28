require 'sinatra'
require "sinatra/activerecord"
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'multi_json'
require 'open-uri'
require 'titleize'
require 'date'
require 'nokogiri'

require_relative "models/contribution"

configure do
  set :database_file, "config/database.yml"
end

# Root
get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# Traffic with gaug.es
get '/traffic' do
  type = params[:type] || "line"
  gauges_params = params.select { |k, v| k.include?("page") }

  graph = {
    graph: {
      title: 'Traffic',
      total: true,
      type: type,
      refreshEveryNSeconds: 300,
      datasequences: [
  
      ]
    }
  }

  gauges_params.each do |key, gauge_id|
    gauge   = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}",
                              "X-Gauges-Token" => params[:api_key]).read)["gauge"]

    traffic = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}/traffic",
                              "X-Gauges-Token" => params[:api_key]).read)["traffic"]

    if gauges_params.size == 1
      views = { title: "Views", datapoints: [] }
      graph[:graph][:title] = gauge["title"]
    else
      views = { title: gauge["title"], datapoints: [] }
    end
    traffic.each do |entry|
      views[:datapoints] << {
        title: DateTime.parse(entry["date"]).strftime("%e.%-m."),
        value: entry["views"]
      }
    end
    graph[:graph][:datasequences] << views
    unless gauges_params.size > 1

      people = { title: "People", datapoints: [] }
      traffic.each do |entry|
        people[:datapoints] << {
          title: DateTime.parse(entry["date"]).strftime("%e.%-m."),
          value: entry["people"]
        }
      end
      graph[:graph][:datasequences] << people
    end
  end
  
  json graph
end

# Subscriber graph with URI.LV
get '/subscribers/graph' do
  type = params[:type] || "line"
  feed_params = params.select { |k, v| k.include?("feed") }

  uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")

  graph = {
    graph: {
      title: 'Subscriber',
      type: type,
      refreshEveryNSeconds: 3600,
      datasequences: [
  
      ]
    }
  }

  feed_params.each do |key, feed|
    parameters = { :key => params[:api_key], :token => params[:token], :feed => feed }
    uri.query = URI.encode_www_form(parameters)
    stats = MultiJson.load(uri.open.read)["stats"].reverse
    if feed_params.size == 1
      graph[:graph][:title] = feed.titleize.gsub('-', ' ')
      greader = { title: "Google Reader", datapoints: [] }
      stats.each do |entry|
        greader[:datapoints] << {
          title: Time.at(entry["day"]).strftime("%e.%-m."),
          value: entry['greader']
        }
      end
      graph[:graph][:datasequences] << greader
      other = { title: "Other", datapoints: [] }
      stats.each do |entry|
        other[:datapoints] << {
          title: Time.at(entry["day"]).strftime("%e.%-m."),
          value: entry['other']
        }
      end
      graph[:graph][:datasequences] << other
      direct = { title: "Direct", datapoints: [] }
      stats.each do |entry|
        direct[:datapoints] << {
          title: Time.at(entry["day"]).strftime("%e.%-m."),
          value: entry['direct']
        }
      end
      graph[:graph][:datasequences] << direct
    else
      subscribers = { title: feed.titleize.gsub('-', ' '), datapoints: [] }
      stats.each do |entry|
        subscribers[:datapoints] << {
          title: Time.at(entry["day"]).strftime("%e.%-m."),
          value: entry['greader'] + entry['other'] + entry['direct']
        }
      end
      graph[:graph][:datasequences] << subscribers
    end
  end

  json graph
end

# Subscriber count with URI.LV
get '/subscribers/count' do
  feed_params = params.select { |k, v| k.include?("feed") }

  uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")
  feeds = []

  feed_params.each do |key, feed|
    parameters = { :key => params[:api_key], :token => params[:token], :feed => feed }
    uri.query = URI.encode_www_form(parameters)
    stats = MultiJson.load(uri.open.read)["stats"].first
    subscribers = stats['greader'] + stats['other'] + stats['direct']
    feeds << {
      name: feed.titleize.gsub('-', ' '),
      count: subscribers
    }

  end

  @feeds = feeds.sort_by { |k| k[:count] }.reverse
  erb :subscribers_count
end

get '/subscribers/table' do
  @uri = "/subscribers/count?" + URI.encode_www_form(params)
  erb :subscribers
end

get '/vigil' do
  @uri = "/vigil/table?" + URI.encode_www_form(params)
  erb :vigil
end

get '/vigil/table' do
  @pages = []

  @return = Nokogiri::HTML(open("http://api.vigil-app.com/v1/user/#{params[:user]}/host?populateHostMonitors&output=html"))

  items = @return.css("tr")
  items.each do |item|
    name = item.at_css("td.name").text
    status = item.at_css("td.status-code").text
    time = item.at_css("td.total-time").text
    speed = item.at_css("td.speed").text

    page = {name: name, status: status, time: time, speed: speed}
    @pages << page
  end

  erb :vigil_table
end

get '/streak' do
  erb :streak
end

get '/streak/number' do
  contributions = Contribution.order("date desc")
  starting_date = Date.today 
  if contributions.first.count == 0
    starting_date -= 1
    breaker = contributions.where(count: 0).second
  else
    breaker = contributions.where(count: 0).first
  end
  @streak = (starting_date - breaker.date).to_i

  @streak.to_s
end