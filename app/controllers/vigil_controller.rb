class VigilController < StatusBoardWidgets
  set :views, "app/views/vigil"

  get '/' do
    @uri = "/vigil/table?" + URI.encode_www_form(params)
    erb :index
  end
  
  get '/table' do
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
  
    erb :table
  end
end