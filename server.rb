# required gem includes
require 'sinatra'
require "sinatra/json"
require 'rack-flash'
require_relative 'lib/rps_app.rb'


set :bind, '0.0.0.0' # Vagrant fix
set :port, '1234'
set :sessions, true
set :session_secret, 'super secret'
use Rack::Flash

# partial
# layouts

get '/' do
  @home = 'js/home.js'
  if session['sesh_example']
    @user = RPS.dbi.get_player_by_username(session['sesh_example'])
    redirect to '/matches'
  end
  erb :index
end

get '/matches' do
  if !session['sesh_example']
    redirect to '/'
  end
  @js = 'js/pushmenu.js'
  @id = RPS.dbi.get_player_id(session['sesh_example'])
  @active_matches = RPS.dbi.active_matches(@id)
  @pending_matches = RPS.dbi.pending_matches(@id)
  @completed_matches = RPS.dbi.completed_matches(@id)
  @all_players = RPS.dbi.get_all_players(@id)
  @current_player = RPS.dbi.get_player_by_id(@id).username
  erb :matches
end

post '/matches' do
  if !session['sesh_example']
    redirect to '/'
  end
  @p1 = RPS.dbi.get_player_id(session['sesh_example'])
  @p2 = RPS.dbi.get_player_id(params['invitee'])

  RPS.dbi.create_player_match(@p1, @p2)

  redirect to '/matches'
end

get '/play' do
  if !session['sesh_example']
    redirect to '/'
  end
  @audio = 'js/audio.js'
  @active_user = true
  @current_player = session['sesh_example']
  erb :play
end

post '/play' do
end

get '/rock' do
  redirect to '/matches'
end

get '/paper' do
  redirect to '/matches'
end

get '/scissors' do
  redirect to '/matches'
end

get '/signup' do
  if session['sesh_example']
    redirect to '/'
  else
    erb :signup
  end
end

post '/signin' do
  sign_in = RPS::SignIn.run(params)

  if sign_in[:success?]
    session['sesh_example'] = sign_in[:session_id]
    redirect to '/matches'
  else
    flash[:alert] = sign_in[:error]
    redirect to '/'
  end
end

post '/signup' do
  sign_up = RPS::SignUp.run(params)

  if sign_up[:success?]
    session['sesh_example'] = sign_up[:session_id]
    redirect to '/matches'
  else
    flash[:alert] = sign_up[:error]
    redirect to '/'
  end 

end

get '/signout' do
  session.clear
  redirect to '/'
end