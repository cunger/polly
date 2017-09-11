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

    class InvalidPassword < RuntimeError ; end

    def authenticate!(alleged_password)
      raise InvalidPassword unless @password == alleged_password
    end
  end

  class GuestUser
    def name
      'guest'
    end
  end
end
