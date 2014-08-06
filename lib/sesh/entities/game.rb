module RPS
  class Game
    # Rock, Paper, Scissors
    # Make a 2-player game of rock paper scissors. It should have the following:
    #
    # It is initialized with two strings (player names).
    # It has a `play` method that takes two strings:
    #   - Each string reperesents a player's move (rock, paper, or scissors)
    #   - The method returns the winner (player one or player two)
    #   - If the game is over, it returns a string stating that the game is already over
    # It ends after a player wins 2 of 3 games
    #
    # You will be using this class in the following class, which will let players play
    # RPS through the terminal.

    attr_reader :player1, :player2, :games

    @@moves = ['rock', 'paper', 'scissors']

    def initialize(player1, player2)
      @player1 = player1
      @player2 = player2
      @games = {total: 0, player1: 0, player2: 0}
    end

    def play(move1, move2)
      move1 = move1.downcase
      move2 = move2.downcase

      if (@games[:total] <= 3)
        if (@@moves.include?(move1)) && (@@moves.include?(move2)) 
          if move1 == move2
            puts "TIE"
          elsif ((move1 == "rock" && move2 == "scissors") || (move1=="scissors" && move2=="paper") || (move1=="paper" && move2=="rock"))
            @games[:player1] += 1    
            puts "#{@player1} Wins!"
            @games[:total] += 1
          else ((move1 == "scissors" && move2 == "rock") || (move1=="paper" && move2=="scissors") || (move1=="rock" && move2=="paper"))
            @games[:player2] += 1
            puts "#{@player2} Wins!"
            @games[:total] += 1
          end
        else
          puts "Incorrect choice format, please choose 'rock', 'paper', or 'scissors'."
        end
      end
      puts "Game over. #{@player1} wins with #{@games[:player1]} points to #{@player2}'s #{@games[:player2]}!" if (@games[:total] == 3) && (@games[:player1] > @games[:player2])
      puts "Game over. #{@player2} wins with #{@games[:player2]} points to #{@player1}'s #{@games[:player2]}!" if (@games[:total] == 3) && (@games[:player2] > @games[:player1])
    end
  end