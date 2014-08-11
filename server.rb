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
  # this sets id based on current username set in session
  # TODO: storing username in session['sesh_example'] is not ideal 

  @active_matches = RPS.dbi.active_matches(@id).sort {|a,b| a['id'].to_i <=> b['id'].to_i}
  @pending_matches = RPS.dbi.pending_matches(@id).sort {|a,b| a['id'].to_i <=> b['id'].to_i}
  @completed_matches = RPS.dbi.completed_matches(@id).sort {|a,b| a['id'].to_i <=> b['id'].to_i}

  # these lines are getting matches based on status and sorting for display

  @all_players = RPS.dbi.get_all_players(@id)

  @current_player = RPS.dbi.get_player_by_id(@id).username
  

  #this builds the tables for the player to view their matches
  #TODO: 

  erb :matches


end

post '/matches' do
  if !session['sesh_example']
    redirect to '/'
  end
  @p1 = RPS.dbi.get_player_id(session['sesh_example'])
  @p2 = RPS.dbi.get_player_id(params['invitee'])
  if @p2
  # p1 is always the player sending the invite
  # p2 is always the player receiving the invite
  # this does not change their position in the table
  # when the player signs up, they receive a permanent id position in the table

  @new_match = RPS.dbi.create_player_match(@p1, @p2)

  # this initiates a new match
  # TODO: create match object here with the create_player_match DBI method? discuss.



  5.times {RPS.dbi.create_game(@new_match.first['id'])}

  #this populates the games table with 5 games all holding the same match ID generated from creating player match
  #TODO: create game objects here with create_game method

  redirect to '/matches'
  else
    flash[:alert] = 'The player you are trying to invite does not exist'
    redirect to '/matches'
  end
end



get '/play/:match' do
  if !session['sesh_example']
    redirect to '/'
  end
  @moves = ['rock', 'paper', 'scissors']
  @match_id = params[:match]
  @match_object = RPS.dbi.get_match(@match_id).first
  @user_id = RPS.dbi.get_player_id(session['sesh_example'])
  # @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')

  # @need to know if player 1 or player 2


  # if @match_object['player1'] == @user_id
  #   if RPS.dbi.get_most_recent_game(match_id, 'player2')
  #   if @player_2_move = RPS.dbi.find_player2_move(@game_id)
  #     .first['player_2_move'] == NULL
  #                    ERROR FLASH
  #   
  #
  if @match_object['player1'] == @user_id
    @player_2_id = RPS.dbi.find_player2_id(@match_id).first['player2'].to_i
    # player_1

    # I AM PLAYER 1
    # I CANNOT PLAY
    # IF I HAVE ALREADY PLAYED
    # AND PLAYER 2 HAS NOT
    @latest_move_string = RPS.dbi.validate_single_game_only(@match_id, 'player_1')
    if @latest_move_string.first != nil 
      puts @latest_move_string.first['player_2_move']
      if !(@moves.include?(@latest_move_string.first['player_2_move']))
        @active_user = RPS.dbi.get_player_by_id(@player_2_id).username


         #---flash[:alert] = "Please wait for the other player to play their move."---
         #---REFUSE ENTRY---x
         #---REDIRECT? TO MATCHES?----


      else
        @active_user = RPS.dbi.get_player_by_id(@user_id).username
                puts @active_user

      end
    else
      @active_user = RPS.dbi.get_player_by_id(@user_id).username
              puts @active_user

    end
    puts @active_user

  end


  if @match_object['player2'] == @user_id
    @player_1_id = RPS.dbi.find_player_1_id(@match_id).first['player1'].to_i
    @latest_move_string = RPS.dbi.validate_single_game_only(@match_id, 'player_2')
    if @latest_move_string.first != nil 
      puts @latest_move_string.first['player_1_move']
      if !(@moves.include?(@latest_move_string.first['player_1_move']))
        @active_user = RPS.dbi.get_player_by_id(@player_1_id).username


         #---flash[:alert] = "Please wait for the other player to play their move."---
         #---REFUSE ENTRY---x
         #---REDIRECT? TO MATCHES?----

      else
        @active_user = RPS.dbi.get_player_by_id(@user_id).username
        puts @active_user
        puts session['sesh_example']
      end
      @active_user = RPS.dbi.get_player_by_id(@user_id).username
      puts @active_user
      puts session['sesh_example']
    end
    # @active_user = RPS.dbi.get_player_by_id(@user_id).username
    puts @active_user
    puts session['sesh_example']

  end

  # @ need to know match we are in 

  # need most recent game


  # if !(LOGIC ABOUT CHECKING IF BOTH MOVES IN A PERVIOUS GAME
  #     HAVE BEEN PLAYED /  if current user has made a move???)
  #   redirect to '/matches'
  #   alert that it is not their turn
  # end

  @audio = 'js/audio.js'
  @match_id = params[:match]
  @match_object = RPS.dbi.get_match(@match_id).first
  RPS.dbi.update_match_status(@match_id, "active")
  @current_player = session['sesh_example']
  erb :play
end

get '/rock/:id' do
  @match_id = params[:id]
  #pulls match id from integer value at the end of the URL

  @match_object = RPS.dbi.get_match(@match_id).first

  # pulls match hash from the database


  @user_id = RPS.dbi.get_player_id(session['sesh_example'])
  # these variables are pulling the match hash from the d

    # ============================================================================

    #                                Player 1

    # ============================================================================


  if @match_object['player1'] == @user_id
    # THIS routes the server to the player 1 sequence
    
    

    @player_2_id = RPS.dbi.find_player2_id(@match_id).first['player2'].to_i
    # THIS CHOOSES PLAYER 2 FROM THE DATABASE
    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_1')
    # This pulls the most recent game from the DBI. get_most_recent_game only checks player_1_moves from 
    # the DBI and returns the most recent game with no player_1_move

    @game_id = @current_game.first['id'].to_i 
    # THIS is a temporary workaround that just takes the @current_game array, grabs the hash, access value for key 'id'
    # and converts to_i


    #TODO:    clunky code, clean up

    RPS.dbi.update_player1_moves(@game_id, 'rock')
    # this UPDATES the player_1_moves column in the current game to the string 'rock'
    # todo: update method names for consistent name spacing throughout all of the code...

    @player_2_move = RPS.dbi.find_player2_move(@game_id).first['player_2_move']
    # this method GETS player 2's move for COMPARISON and to determine winner of the match


    # ============================================================================

    #                         Compare Moves to determine Winner!

    # ============================================================================


    if @player_2_move == 'scissors'
      RPS.dbi.set_game_winner(@game_id, @user_id) 
      # this populates the game table with the user_id of the player as ROCK beats scissors. 
      # player 1 wins

      # todo: INCORPORATE ruby object, update object AND database with new outcome
        

    elsif @player_2_move == 'paper'
      RPS.dbi.set_game_winner(@game_id, @player_2_id)
      # this populates the game table with the user_id of the player as ROCK loses to paper. 
      # player 2 wins

      # todo: INCORPORATE ruby object, update object AND database with new outcome

    elsif @player_2_move == 'rock'
      RPS.dbi.nullify_player_moves(@game_id) 


      # this outcome is a TIE! the games table is accessed in the dbi and the previous moves are erased
      # when the next game is played, it will be accessing the same game_id that player_1's move was
      # stored in previously. 

      #ex. player_2_move was rock in game_id #2. player 1 chooses rock. player_2_move's rock entry is erased
      # game_id #2 is fresh. next moves populate game_id #2


      flash[:alert] = 'TIE! RESETTING GAME...'
      redirect to '/play/#{@match_id}'
      # alerts user of the tie
      erb :play
    end

    # ============================================================================

    #                the battle has been won, but what of the war?


    #                   Let's Tally and see if the match winner
    #                            has been determined!

    # ===========================================================================
    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count

    # this variable stores the number of wins for player 1.

    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_2_id).count

    # this variable stores the number of wins for player 2.

    # DETERMINING MATCH WINNER (if there is one)

    # ============================================================================

    #                                if someone has won
    #                               3 games in the match

    # ============================================================================

    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
      RPS.dbi.update_match_status(@match_id, "completed")

      # this route sets match winner, updates status to completed

      # TODO: flash message that the player has won? also update object
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_2_id)
      RPS.dbi.update_match_status(@match_id, "completed")

      # this route sets match winner, updates status to completed

      # TODO: flash message that the player has won? also update object
    end


    # ============================================================================



    # ============================================================================


    # ============================================================================

    #                                    Player 2

    # ============================================================================


  elsif @match_object['player2'] == @user_id
    @player_1_id = RPS.dbi.find_player_1_id(@match_id).first['player1'].to_i

    @current_game = RPS.dbi.get_most_recent_game(@match_id, 'player_2')

    @game_id = @current_game.first['id'].to_i 

    RPS.dbi.update_player2_moves(@game_id, 'rock')
    @player_1_move = RPS.dbi.find_player1_move(@game_id).first['player_1_move']

    if @player_1_move == 'scissors'
      RPS.dbi.set_game_winner(@game_id, @user_id)
        
    elsif @player_1_move == 'paper'
      RPS.dbi.set_game_winner(@game_id, @player_1_id)

    elsif @player_1_move == 'rock'
    
      RPS.dbi.nullify_player_moves(@game_id) 
      flash[:alert] = 'TIE! RESETTING GAME...'
      redirect to '/play/#{@match_id}'

    end

    @count_wins = RPS.dbi.count_match_winner(@match_id, @user_id).count
    @opposing_wins = RPS.dbi.count_match_winner(@match_id, @player_1_id).count
    if @count_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @user_id)
      RPS.dbi.update_match_status(@match_id, "completed")
    elsif @opposing_wins >= 3
      RPS.dbi.set_match_winner(@match_id, @player_1_id)
      RPS.dbi.update_match_status(@match_id, "completed")

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
      flash[:alert] = 'TIE! RESETTING GAME...'
      redirect to '/play/#{@match_id}'
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
      flash[:alert] = 'TIE! RESETTING GAME...'
      redirect to '/play/#{@match_id}' 

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
  @home = 'js/home.js'
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
    @home = 'js/home.js'
    flash[:alert] = sign_in[:error]
    erb :index
  end
end

post '/signup' do
  sign_up = RPS::SignUp.run(params)

  if sign_up[:success?]
    session['sesh_example'] = sign_up[:session_id]
    redirect to '/matches'
  else
    @home = 'js/home.js'
    flash[:alert] = sign_up[:error]
    erb :index
  end 

end

get '/signout' do
  session.clear
  redirect to '/'
end