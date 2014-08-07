require 'digest/sha1'

module RPS
  class User
    attr_reader :username, :password_digest, :wins, :losses

    def initialize(username, password_digest=nil)
      @username = username
      @password_digest = password_digest
      @wins = 0
      @losses = 0
    end

    def update_password(password)
      @password_digest = Digest::SHA1.hexdigest(password)
    end

    def has_password?(password)
      Digest::SHA1.hexdigest(password) == @password_digest
    end
  end
end