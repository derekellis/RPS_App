require 'pg'
require 'digest/sha1'

module RPS
  class DBI
    attr_reader :db
    def initialize
      @db = PG.connect(host: 'localhost', dbname: 'rock_paper_scissors')

      players = %q[
        CREATE TABLE IF NOT EXISTS players(
          id SERIAL,
          username text,
          password text,
          PRIMARY KEY (id)
          );]
      @db.exec(players)


      matches = %q[
        CREATE TABLE IF NOT EXISTS matches(
          id SERIAL,
          player1 integer REFERENCES players(id),
          player2 integer REFERENCES players(id),
          winner integer REFERENCES players(id),
          status text,
          PRIMARY KEY ( id )
          );]
      @db.exec(matches)

      games = %q[
        CREATE TABLE IF NOT EXISTS games(
          id SERIAL,
          player_1_move text,
          player_2_move text,
          match_id integer REFERENCES matches(id),
          winner integer,
          PRIMARY KEY ( id )
          );]
      @db.exec(games)


      sessiontable = %q[
        CREATE TABLE IF NOT EXISTS sessions(
          id SERIAL,
          userid integer REFERENCES players(id),
          sessionid text,
          PRIMARY KEY ( id )
          );]
      @db.exec(sessiontable)


    end

    def persist_user(user)
      @db.exec(%q[
        INSERT INTO players (username, password)
        VALUES ($1, $2);
      ], [user.username, user.password_digest])
    end

    def create_player(username, password)
      create = <<-SQL
      INSERT INTO players (username, password)
      VALUES ('#{username}', '#{password}')
      RETURNING id;
      SQL
      @db.exec(create)
    end

    def username_exists?(username)
      result = @db.exec(%Q[
        SELECT * FROM players WHERE username = '#{username}';
      ])

      if result.count > 0
        true
      else
        false
      end
    end

    def get_player(id)
      get = <<-SQL
      SELECT * FROM players WHERE id = id;
      SQL
      @db.exec(get)
    end

    def build_user(data)
      RPS::User.new(data['username'], data['password'])
    end

    def get_player_by_username(username)
      result = @db.exec(%Q[
        SELECT * FROM players WHERE username = '#{username}';
      ])

      user_data = result.first
      
      if user_data
        build_user(user_data)
      else
        nil
      end
    end

    def get_player_id(username)
      result = @db.exec(%Q[
        SELECT * FROM players WHERE username = '#{username}';
      ])

      user_data = result.first
      
      if user_data
        user_data['id']
      else
        nil
      end
    end

    def createsesh (userid)
      sessionid = Digest::SHA1.hexdigest userid
      insert = <<-SQL
      INSERT INTO sessions (sessionid, userid)
      VALUES ('#{sessionid}', #{userid});
      SQL
      @db.exec(insert)
      sessionid
    end

    def update_password(password, user_id)
      update = <<-SQL
      UPDATE players SET
      password = '#{password}'
      WHERE id = #{user_id};
      SQL
      @db.exec(update)
    end

    def create_player_match(player1, player2)
      create = <<-SQL
      INSERT INTO matches(player1, player2)
      VALUES (#{player1}, #{player2})
      RETURNING id;
      SQL
      @db.exec(create)
    end

    def get_match(match_id)
      get = <<-SQL
      SELECT * FROM matches WHERE id = #{match_id};
      SQL
      @db.exec(get)
    end

    def create_game(match_id)
      create = <<-SQL
      INSERT INTO games (match_id)
      VALUES(#{match_id})
      RETURNING id;
      SQL
      @db.exec(create)
    end

    def get_move(game_id)
      get = <<-SQL
      SELECT * from games WHERE id = #{game_id};
      SQL
      @db.exec(get)
    end

    def display_matches(user_id)
      select = <<-SQL
      SELECT * FROM matches WHERE player1 = #{user_id} OR player2 = #{user_id};
      SQL
      @db.exec(select)
    end

    def active_matches(user_id)
      select = <<-SQL
      SELECT * FROM matches WHERE player1 = #{user_id} OR player2 = #{user_id} AND status = 'active';
      SQL
      @db.exec(select)
    end

    def pending_matches(user_id)
      select = <<-SQL
      SELECT * FROM matches WHERE player1 = #{user_id} OR player2 = #{user_id} AND status = 'pending';
      SQL
      @db.exec(select)
    end

    def completed_matches(user_id)
      select = <<-SQL
      SELECT * FROM matches WHERE player1 = #{user_id} OR player2 = #{user_id} AND status = 'completed';
      SQL
      @db.exec(select)
    end

    def games_by_match(match_id)
      select =<<-SQL
      SELECT * FROM games WHERE match_id = #{match_id};
      SQL
      @db.exec(select)
    end

    def match_by_match_id(match_id)
      select = <<-SQL
      SELECT * FROM matches WHERE id = #{match_id};
      SQL
      @db.exec(select)
    end

    def get_most_recent_game(match_id)
      check = <<-SQL
      SELECT * FROM games WHERE match_id = #{match_id}
      ORDER BY id DESC LIMIT 1;
      SQL
      @db.exec(check)
    end

    def update_player1_moves(game_id, move)
      update = <<-SQL
      UPDATE games SET 
      player_1_move = '#{move}'
      WHERE id = #{game_id};
      SQL
      @db.exec(update)
    end

    def update_player2_moves(game_id, move)
      update = <<-SQL
      UPDATE games SET 
      player_2_move = '#{move}'
      WHERE id = #{game_id};
      SQL
      @db.exec(update)
    end

    def set_game_winner(game_id, winner)
      set = <<-SQL
      UPDATE games SET 
      winner = #{winner}
      WHERE id = #{game_id};
      SQL
      @db.exec(set)
    end

    def set_match_winner(match_id, winner)
      set = <<-SQL
      UPDATE matches SET 
      winner = #{winner}
      WHERE id = #{match_id};
      SQL
      @db.exec(update)
    end
  end

  def self.dbi
    @__db_instance || DBI.new
  end

end