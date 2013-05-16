require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

# Root
get '/' do
  "Sinatra has taken the stage .."
end
