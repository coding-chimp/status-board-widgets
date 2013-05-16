require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?
require 'multi_json'
require 'open-uri'

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
    gauge   = JSON.parse(open("https://secure.gaug.es/gauges/#{gauge_id}",
                              "X-Gauges-Token" => api_key).read)["gauge"]

    traffic = JSON.parse(open("https://secure.gaug.es/gauges/#{gauge_id}/traffic",
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