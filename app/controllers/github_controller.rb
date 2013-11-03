require_relative "../models/contribution"

class GithubController < StatusBoardWidgets
  set :views, "app/views/github"

  get '/' do
    @uri = "/github/data?" + URI.encode_www_form(params || []).to_s
    erb :index
  end

  get '/data' do
    if params['username']
      if params['token']
        client = Octokit::Client.new(access_token: params[:token])
        @user = client.user
        @notifications = client.notifications.count
      else
        @user = Octokit.user params[:username]
      end
      erb :data
    elsif ENV['GITHUB_TOKEN']
      client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
      @user = client.user
      @notifications = client.notifications.count
      erb :data
    else
      "No username given."
    end
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
end
