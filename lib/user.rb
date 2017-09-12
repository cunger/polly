require 'bcrypt'

module Polly
  class User
    attr_reader :name, :password

    def initialize(name, password)
      @name = name
      @password = password
    end

    def self.create(name, password)
      self.new(name, BCrypt::Password.create(password))
    end

    def self.load(name, password)
      self.new(name, BCrypt::Password.new(password))
    end

    def signed_in?
      true
    end

    def authenticate!(alleged_password)
      raise AuthenticationFailure unless @password == alleged_password
      true
    end

    def update_password(new_password)
      @password = BCrypt::Password.create new_password
    end

    class AuthenticationFailure < RuntimeError ; end
  end

  class GuestUser
    def name
      'guest'
    end

    def signed_in?
      false
    end
  end
end
