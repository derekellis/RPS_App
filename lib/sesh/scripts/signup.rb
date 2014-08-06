module RPS
  class SignUp
    def self.run(params)
      if params['username'].empty? || params['password'].empty? || params['password_conf'].empty?
        return {:success? => false, :error => "EMPTY FIELDS"}
      elsif Sesh.dbi.username_exists?(params['username'])
        return {:success? => false, :error => "USER ALREADY EXISTS"}
      elsif params['password'] != params['password_conf']
        return {:success? => false, :error => "PASSWORDS DON'T MATCH"}
      end

      user = RPS::User.new(params['username'])
      user.update_password(params['password'])
      RPS.dbi.persist_user(user)

      {
        :success? => true,
        :session_id => user.username
      }
    end
  end
end