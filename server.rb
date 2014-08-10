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

before do
  @root = 'http://10.10.10.10:4567/'
end

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
  @active_matches = RPS.dbi.active_matches(@id).sort {|a,b| a['id'] <=> b['id']}
  @pending_matches = RPS.dbi.pending_matches(@id).sort {|a,b| a['id'] <=> b['id']}
  @completed_matches = RPS.dbi.completed_matches(@id).sort {|a,b| a['id'] <=> b['id']}
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
    @player_2_id = RPS.dbi.find_player2_id(@match_id).first['player2'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player1_moves(@game_id, 'rock')
    @player_2_move = RPS.dbi.find_player2_move(@game_id).first['player_2_move']
    # ^^^^^^^^ THIS IS A STRING 
    if @player_2_move == 'scissors'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        

    elsif @player_2_move == 'paper'
      RPS.dbi.set_game_winner(@game_id, @player_2_id)

    elsif @player_2_move == 'rock'


      #TRYING TO ERASE BOTH MOVES FROM BOTH PLAYERS!!!!!!!!!
      RPS.dbi.nullify_player_moves(@game_id) 


    end

    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_2_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_2_id)
    end




  elsif @match_object['player2'] == @user_id
    @player_1_id = RPS.dbi.find_player_1_id(@match_id).first['player1'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player2_moves(@game_id, 'rock')
    @player_1_move = RPS.dbi.find_player1_move(@game_id).first['player_1_move']
    # ^^^^^^^^ THIS IS A STRING 
    if @player_1_move == 'scissors'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        
    elsif @player_1_move == 'paper'
      RPS.dbi.set_game_winner(@game_id, @player_1_id)

    elsif @player_1_move == 'rock'
    
      RPS.dbi.nullify_player_moves(@game_id) 

    end

    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_1_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_1_id)
    end


  end
  #CHECK FOR WINNER

  redirect to '/matches'
end

get '/paper/:id' do
  @match_id = params[:id]
  @match_object = RPS.dbi.get_match(@match_id).first
  @user_id = RPS.dbi.get_player_id(session['sesh_example'])

  if @match_object['player1'] == @user_id
    @player_2_id = RPS.dbi.find_player2_id(@match_id).first['player2'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player1_moves(@game_id, 'paper')
    @player_2_move = RPS.dbi.find_player2_move(@game_id).first['player_2_move']
    # ^^^^^^^^ THIS IS A STRING 
    if @player_2_move == 'rock'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        

    elsif @player_2_move == 'scissors'
      RPS.dbi.set_game_winner(@game_id, @player_2_id)

    elsif @player_2_move == 'paper'
    
      RPS.dbi.nullify_player_moves(@game_id) 

    end

    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_2_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_2_id)
    end




    # else 
     #   USE @current_game.first['id'].to_i FOR GAME PARAMETER
    #     UPDATE games SET player_1_move = NULL AND player_2_move = NULL 
    #     WHERE id = #{game_id};


    # WHERE id = @current_game.first['id'].to_i
    # this will set the winner integer column in games equal to the
    # id of the winner

    # FUTURE TODO: set match winner if winner > 3 instances

  elsif @match_object['player2'] == @user_id
    @player_1_id = RPS.dbi.find_player_1_id(@match_id).first['player1'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player2_moves(@game_id, 'paper')
    @player_1_move = RPS.dbi.find_player1_move(@game_id).first['player_1_move']
    # ^^^^^^^^ THIS IS A STRING 
    if @player_1_move == 'rock'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        
    elsif @player_1_move == 'scissors'
      RPS.dbi.set_game_winner(@game_id, @player_1_id)
    elsif @player_1_move == 'paper'
    
      RPS.dbi.nullify_player_moves(@game_id) 
    end
    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_1_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_1_id)
    end
  end
  #CHECK FOR WINNER

  redirect to '/matches'
end

get '/scissors/:id' do
  @match_id = params[:id]
  @match_object = RPS.dbi.get_match(@match_id).first
  @user_id = RPS.dbi.get_player_id(session['sesh_example'])
  if @match_object['player1'] == @user_id
    @player_2_id = RPS.dbi.find_player2_id(@match_id).first['player2'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player1_moves(@game_id, 'scissors')
    @player_2_move = RPS.dbi.find_player2_move(@game_id).first['player_2_move']
    # ^^^^^^^^ THIS IS A STRING 
    if @player_2_move == 'paper'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        

    elsif @player_2_move == 'rock'
      RPS.dbi.set_game_winner(@game_id, @player_2_id)
    elsif @player_2_move == 'scissors'
    
      RPS.dbi.nullify_player_moves(@game_id) 

    end
    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_2_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_2_id)
    end




  elsif @match_object['player2'] == @user_id
    @player_1_id = RPS.dbi.find_player_1_id(@match_id).first['player1'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')
    #THIS IS A PG OBJECT UGH
    @game_id = @current_game.first['id'].to_i #THIS IS AN INTEGER

    RPS.dbi.update_player2_moves(@game_id, 'scissors')
    @player_1_move = RPS.dbi.find_player1_move(@game_id).first['player_1_move']
    # ^^^^^^^^ THIS IS A STRING 
    if @player_1_move == 'paper'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        
    elsif @player_1_move == 'rock'
      RPS.dbi.set_game_winner(@game_id, @player_1_id)
    elsif @player_1_move == 'scissors'
    
      RPS.dbi.nullify_player_moves(@game_id) 

    end
    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_1_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_1_id)
    end
  end
  #CHECK FOR WINNER

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