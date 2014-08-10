# required gem includes
require 'sinatra'
require "sinatra/json"
require 'rack-flash'
require_relative 'lib/rps_app.rb'


set :bind, '0.0.0.0' # Vagrant fix
set :port, '4567'
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

  @new_match = RPS.dbi.create_player_match(@p1, @p2)

  5.times {RPS.dbi.create_game(@new_match.first['id'])}

  redirect to '/matches'
end

# get '/play' do
#   if !session['sesh_example']
#     redirect to '/'
#   end
#   @audio = 'js/audio.js'
#   @active_user = true
#   @current_player = session['sesh_example']
#   erb :play
# end

get '/play/:match' do
  if !session['sesh_example']
    redirect to '/'
  end
  @audio = 'js/audio.js'
  @active_user = true
  @match_id = params[:match]
  @match_object = RPS.dbi.get_match(@match_id).first
  RPS.dbi.update_match_status(@match_id, "active")
  @current_player = session['sesh_example']
  erb :play
end

get '/rock/:id' do
  @match_id = params[:id]
  puts 'match_id:'
  puts @match_id
  @match_object = RPS.dbi.get_match(@match_id).first
  puts 'match_object:'
  puts @match_object
  @user_id = RPS.dbi.get_player_id(session['sesh_example'])
  puts 'user_id'
  puts @user_id
  if @match_object['player1'] == @user_id
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    # SCORRRRRRRRRE!!!!!!!! 
    # MAJOR BUG
    # changed get_most_recent_game from selecting * from games. Now 'id's from games.
    # !!!!!!.first['id'].to_i FOR WHEN YOU ARE PASSING AN INTEGER TO SQL
    # DBI METHOD!!!!
    RPS.dbi.update_player1_moves(@current_game.first['id'].to_i, 'rock')
  elsif @match_object['player2'] == @user_id
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')
    RPS.dbi.update_player2_moves(@current_game.first['id'].to_i,'rock')
  end

  redirect to '/matches'
end

get '/paper/:id' do
  @match_id = params[:id]
  @match_object = RPS.dbi.get_match(@match_id).first
  @user_id = RPS.dbi.get_player_id(session['sesh_example'])
  if @match_object['player1'] == @user_id
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player1_moves(@current_game.first['id'].to_i, 'paper')

    # player_1 move is paper
    # game_id = id @current_game.first['id'].to_i
    
  


    # DECLARING VARIABLES NEEDED FOR LOGIC AND SHIT
    


    # @player_2_id = RPS.dbi.find_player2_id(@match_id).first['id'].to_i


    # @player_2_move = find_player2_move(@game_id).first['player_2_move']
    # ^^^^^^^^ THIS IS A STRING 



    # if @opposition_choice['player_2_move'] == 'rock'
      # RPS.dbi.set_game_winner(@current_game.first['id'].to_i, @user_id)
        

    # if @opposition_choice['player_2_move'] == 'scissors'
      # RPS.dbi.set_game_winner(@current_game.first['id'].to_i, @player_2)

    # else 
    #   USE @current_game.first['id'].to_i FOR GAME PARAMETER
    #     UPDATE games SET player_1_move = NULL AND player_2_move = NULL 
    #     WHERE id = #{game_id};


    # WHERE id = @current_game.first['id'].to_i
    # this will set the winner integer column in games equal to the
    # id of the winner































    # FUTURE TODO: set match winner if winner > 3 instances

  elsif @match_object['player2'] == @user_id
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')
    RPS.dbi.update_player2_moves(@current_game.first['id'].to_i,'paper')
    # @match_id
    # player_2
    # player_2 move is paper
    # need player_1 move

  end

  redirect to '/matches'
end

get '/scissors/:id' do
  @match_id = params[:id]
  @match_object = RPS.dbi.get_match(@match_id).first
  @user_id = RPS.dbi.get_player_id(session['sesh_example'])
  if @match_object['player1'] == @user_id
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    RPS.dbi.update_player1_moves(@current_game.first['id'].to_i, 'scissors')
  elsif @match_object['player2'] == @user_id
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')
    RPS.dbi.update_player2_moves(@current_game.first['id'].to_i,'scissors')
  end
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