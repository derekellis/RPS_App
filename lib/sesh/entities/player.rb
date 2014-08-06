module RPS
  class Player
    attr_reader :name, :wins

    def initialize(name)
      @name = name
      @wins = 0
      @losses = 0
    end
  end
end