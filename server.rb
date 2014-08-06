# required gem includes
require 'sinatra'
require "sinatra/json"
#require_relative 'lib/sesh.rb'

set :bind, '0.0.0.0' # Vagrant fix
set :sessions, true
set :session_secret, 'super secret'

# partial
# layouts

get '/' do
  @home = 'js/home.js'
  erb :index
end

get '/matches' do
  @js = 'js/pushmenu.js'
  @matches = nil#Sesh.dbi.get_all_matches(username)
  erb :matches
end

get '/signin' do
  user = Sesh.dbi.get_user_by_username(params['username'])
  if user && user.has_password?(params['password'])
    session['sesh_example'] = user.username
    redirect to '/matches'
  else
    "THAT'S NOT THE RIGHT PASSWORD!!!!"
  end
end

get '/play' do
  @audio = 'js/audio.js'
  @active_user = true
  @current_player = 'Player 1'
  erb :play
end

get '/signout' do
  session.clear
  redirect to '/'
end

post '/signup' do
  redirect to '/'
end