require 'open-uri'
require 'multi_json'

require_relative "../models/contribution"

class FetchContributions
  def initialize
    @user = ENV['GITHUB_USERNAME']
    @token = ENV['GITHUB_TOKEN']
  end

  def fetch_today
    @today = Date.today
    @count = 0

    res = open("https://api.github.com/users/#{@user}/events",
               'Authorization' => "token #{@token}").read

    json = JSON.parse(res)

    json.each do |action|
      date = Date.parse(action['created_at'])
      if date == @today
        case action['type']
          when "PushEvent"
            @count += action['payload']['size']
          when "GistEvent"
            @count += 1
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

    for page in 1..10 do

      res = open("https://api.github.com/users/#{@user}/events?page=#{page}",
                 'Authorization' => "token #{@token}").read

      json = JSON.parse(res)

      json.each do |action|
        case action['type']
          when "PushEvent"
            @increase = action['payload']['size']
          when "GistEvent"
            @increase = 1
          else
            next
        end

        date = Date.parse(action['created_at'])
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