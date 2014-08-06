module RPS
  class Match

    attr_reader :player1, :player2, :games

    @@moves = ['rock', 'paper', 'scissors']

    def initialize(player1, player2)
      @player1 = player1.name
      @player2 = player2.name
      @games = []
      @gameCount = 0
      @winCount = {@player1 => 0, @player2 => 0}
    end

    def play(move1, move2)
      @move1 = move1.downcase
      @move2 = move2.downcase

      if (@gameCount <= 5)
        if (@@moves.include?(@move1)) && (@@moves.include?(@move2)) 
          if @move1 == @move2
            puts "TIE"
          elsif ((@move1 == "rock" && @move2 == "scissors") || (@move1=="scissors" && @move2=="paper") || (@move1=="paper" && @move2=="rock"))
            @winCount[@player1] += 1    
            puts "#{@player1} Wins!"
            @gameCount += 1
            @games << [@move1, @move2]
          else ((@move1 == "scissors" && @move2 == "rock") || (@move1=="paper" && @move2=="scissors") || (@move1=="rock" && @move2=="paper"))
            @winCount[@player2] += 1
            puts "#{@player2} Wins!"
            @gameCount += 1
            @games << [@move1, @move2]
          end
        else
          puts "Incorrect choice format, please choose 'rock', 'paper', or 'scissors'."
        end
      end
      puts "Game over. #{@player1} wins with #{@winCount[@player1]} points to #{@player2}'s #{@winCount[@player2]}!" if (@winCount[:total] == 3) && (@winCount[@player1] > @winCount[@player2])
      puts "Game over. #{@player2} wins with #{@winCount[@player2]} points to #{@player1}'s #{@winCount[@player2]}!" if (@winCount[:total] == 3) && (@winCount[@player2] > @winCount[@player1])
    end
  end
end