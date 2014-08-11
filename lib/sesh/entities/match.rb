module RPS
  class Match
    attr_accessor :id, :player_1, :player_2, :winner

    def initialize(id, player_1, player_2 = nil, winner = nil)
      @id = id
      @player_1 = player_1
      @player_2 = player_2
      @winner = winner
      @games = {}
    end

    def fills(game)


  end
end