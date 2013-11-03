require 'octokit'

require_relative "../models/contribution"

class FetchContributions
  def initialize
    @user = ENV['GITHUB_USERNAME']
    @token = ENV['GITHUB_TOKEN']
  end

  def fetch_today
    @today = Date.today
    @count = 0

    client = Octokit::Client.new(access_token: @token)
    events = client.user_events(@user)

    events.each do |event|
      date = Date.parse(event.created_at)
      if date == @today
        case event.type
          when "PushEvent"
            @increase = event.payload['size']
          when "CreateEvent", "IssuesEvent", "CommitCommentEvent", "PullRequestEvent"
            @increase = 1
        end
      else
        break
      end
    end
    write_contribution(@today, @count)
  end

  def fetch_history
    @current_date = Date.today
    @count = 0
    @increase = 0
    @client = Octokit::Client.new(access_token: @token)

    for page in 1..10 do
      events = @client.user_events(@user, page: page)

      events.each do |event|
        case event.type
          when "PushEvent"
            @increase = event.payload['size']
          when "CreateEvent", "IssuesEvent", "CommitCommentEvent", "PullRequestEvent"
            @increase = 1
          else
            next
        end

        date = Date.parse(event.created_at)
        if date == @current_date
          @count += @increase
        elsif date == @current_date - 1
          write_contribution(@current_date, @count)
          @current_date = date
          @count = @increase
        else
          distance = (@current_date - date) - 1
          for n in 1..distance do
            write_contribution(@current_date - n, 0)
          end
          @current_date = date
          @count = @increase
        end
      end
    end
    write_contribution(@current_date, @count)
  end

  private

  def write_contribution(date, count)
    contribution = Contribution.find_by_date(date)
    if contribution.nil?
      Contribution.create(date: date, count: count)
    else
      contribution.update_attributes(count: count)
    end
  end

end
