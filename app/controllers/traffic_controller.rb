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
        datasequences: []
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
        title = "Views"
        graph[:graph][:title] = gauge["title"]
        people = { title: "People", datapoints: create_datapoints(traffic, "people", beginning, ending) }
        graph[:graph][:datasequences] << people
      else
        title = gauge["title"]
      end

      views = { title: title, datapoints: create_datapoints(traffic, "views", beginning, ending) }
      graph[:graph][:datasequences] << views
    end
    
    json graph
  end

  private

  def create_datapoints(traffic, type, beginning, ending)
    datapoints = []
    traffic[beginning..ending].each do |entry|
      datapoints << {
        title: DateTime.parse(entry["date"]).strftime("%e.%-m."),
        value: entry[type]
      }
    end
    datapoints
  end
end