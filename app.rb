require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'multi_json'
require 'open-uri/cached'
require 'titleize'

# Root
get '/' do
  "Sinatra has taken the stage .."
end

# Traffic with gaug.es
get '/traffic' do
  api_key = params[:api_key]
  params.delete('api_key')

  graph = {
    graph: {
      title: 'Traffic',
      total: true,
      type: "line",
      refreshEveryNSeconds: 300,
      datasequences: [
  
      ]
    }
  }

  params.each do |key, gauge_id|
    gauge   = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}",
                              "X-Gauges-Token" => api_key).read)["gauge"]

    traffic = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}/traffic",
                              "X-Gauges-Token" => api_key).read)["traffic"]

    views = { title: gauge["title"], datapoints: [] }
    traffic.each do |entry|
      views[:datapoints] << {
        title: DateTime.parse(entry["date"]).strftime("%e.%-m."),
        value: entry["views"]
      }
    end
    graph[:graph][:datasequences] << views
  end
  
  json graph
end

# Subscriber graph with URI.LV
get '/subscribers/graph' do
  api_key = params[:api_key]
  params.delete('api_key')
  token = params[:token]
  params.delete('token')

  uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")

  graph = {
    graph: {
      title: 'Subscriber',
      type: "line",
      refreshEveryNSeconds: 300,
      datasequences: [
  
      ]
    }
  }

  params.each do |key, feed|
    parameters = { :key => api_key, :token => token, :feed => feed }
    uri.query = URI.encode_www_form(parameters)
    stats = MultiJson.load(uri.open.read)["stats"]
    subscribers = { title: feed.titleize.gsub('-', ' '), datapoints: [] }
    stats.each do |entry|
      subscribers[:datapoints] << {
        title: Time.at(entry["day"]).strftime("%e.%-m."),
        value: entry['greader'] + entry['other'] + entry['direct']
      }
    end
    graph[:graph][:datasequences] << subscribers
  end

  json graph
end

# Subscriber count with URI.LV
get '/subscribers/count' do
  api_key = params[:api_key]
  params.delete('api_key')
  token = params[:token]
  params.delete('token')

  uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")
  array = []

  params.each do |key, feed|
    parameters = { :key => api_key, :token => token, :feed => feed }
    uri.query = URI.encode_www_form(parameters)
    stats = MultiJson.load(uri.open.read)["stats"].first
    subscribers = stats['greader'] + stats['other'] + stats['direct']
    array << {
      feed: feed.titleize.gsub('-', ' '),
      count: subscribers
    }
  end

  json array
end

get '/subscribers/table' do
  @uri = "/subscribers/count?" + URI.encode_www_form(params)
  erb :subscribers
end