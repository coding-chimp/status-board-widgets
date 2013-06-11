class SubscribersController < StatusBoardWidgets
  set :views, "app/views/subscribers"

  # Subscriber graph with URI.LV
  get '/graph' do
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
            value: entry['greader']
          }
        end
        graph[:graph][:datasequences] << subscribers
      end
    end
  
    json graph
  end
  
  # Subscriber count with URI.LV
  get '/count' do
    feed_params = params.select { |k, v| k.include?("feed") }
  
    uri = URI.parse("http://api.uri.lv/feeds/subscribers.json")
    feeds = []
  
    feed_params.each do |key, feed|
      parameters = { :key => params[:api_key], :token => params[:token], :feed => feed }
      uri.query = URI.encode_www_form(parameters)
      stats = MultiJson.load(uri.open.read)["stats"].first
      feeds << {
        name: feed.titleize.gsub('-', ' '),
        count: stats['greader']
      }
  
    end
  
    @feeds = feeds.sort_by { |k| k[:count] }.reverse
    erb :count
  end
  
  get '/table' do
    @uri = "/subscribers/count?" + URI.encode_www_form(params)
    erb :index
  end
end