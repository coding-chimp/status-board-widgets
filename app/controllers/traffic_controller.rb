class TrafficController < StatusBoardWidgets
  # Traffic graph with gaug.es
  get '/' do
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
  
      date = Date.today - 30
  
      traffic1 = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}/traffic?date=#{date}",
                                "X-Gauges-Token" => params[:api_key]).read)["traffic"]
  
      traffic2 = MultiJson.load(open("https://secure.gaug.es/gauges/#{gauge_id}/traffic",
                                "X-Gauges-Token" => params[:api_key]).read)["traffic"]
  
      traffic = traffic1 + traffic2
      
      ending = traffic.size - 1
      beginning = ending - 30
  
      if gauges_params.size == 1
        views = { title: "Views", datapoints: [] }
        graph[:graph][:title] = gauge["title"]
      else
        views = { title: gauge["title"], datapoints: [] }
      end
      traffic[beginning..ending].each do |entry|
        views[:datapoints] << {
          title: DateTime.parse(entry["date"]).strftime("%e.%-m."),
          value: entry["views"]
        }
      end
      graph[:graph][:datasequences] << views
      unless gauges_params.size > 1
  
        people = { title: "People", datapoints: [] }
        traffic[beginning..ending].each do |entry|
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

end