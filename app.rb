require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'multi_json'
require 'open-uri'
require 'titleize'
require 'date'

# Root
get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# Traffic with gaug.es
get '/traffic' do
  api_key = params[:api_key]
  gauges_params = params.select { |k, v| k.include?("page") }

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

  gauges_params.each do |key, gauge_id|
    gauge   = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}",
                              "X-Gauges-Token" => api_key).read)["gauge"]

    traffic = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}/traffic",
                              "X-Gauges-Token" => api_key).read)["traffic"]

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
  api_key = params[:api_key]
  token = params[:token]
  feed_params = params.select { |k, v| k.include?("feed") }

  uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")

  graph = {
    graph: {
      title: 'Subscriber',
      type: "line",
      refreshEveryNSeconds: 3600,
      datasequences: [
  
      ]
    }
  }

  feed_params.each do |key, feed|
    parameters = { :key => api_key, :token => token, :feed => feed }
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
  api_key = params[:api_key]
  token = params[:token]
  feed_params = params.select { |k, v| k.include?("feed") }

  uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")
  feeds = []

  feed_params.each do |key, feed|
    parameters = { :key => api_key, :token => token, :feed => feed }
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