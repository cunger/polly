require 'bcrypt'

module Polly
  class User
    attr_reader :name

    def initialize(name, password)
      @name = name
      @hashed_password = hash password
    end

    def valid_password?(string)
      @hashed_password == string
    end

    private

    def hash(password)
      if password.is_a? BCrypt::Password
        password
      else
        BCrypt::Password.create password
      end
    end
  end

  class GuestUser
    def name
      'guest'
    end
  end
end
