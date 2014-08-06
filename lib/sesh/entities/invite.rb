module RPS
  class Invite
    attr_reader :pending, :inviter, :invitee

    def initialize(inviter, invitee)
      @status = :pending
      @inviter = inviter
      @invitee = invitee
    end

    def accept!
      @status = :accepted
      RPS::Match.new(@inviter, @invitee)
    end

  end
end
