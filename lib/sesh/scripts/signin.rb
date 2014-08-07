module RPS
  class SignIn
    def self.run(params)
      if params['username'].empty? || params['password'].empty?
        return {:success => false, :error => "BLANK ENTRIES"}
      end

      user = RPS.dbi.get_player_by_username(params['username'])
      return {:success? => false, :error => "NO SUCH USER"} if !user

      if !user.has_password?(params['password'])
        return {:success? => false, :error => "BAD PASSWORD"}
      end

      {
        :success? => true,
        :session_id => user.username
      }
    end
  end
end