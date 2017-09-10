require 'sysrandom/securerandom'
require 'bcrypt'

module Polly
  class Users
    def fetch
      # go through all users and pick the one with a matching name
      GuestUser.new
    end
  end

  class User
    attr_reader :id, :name

    def initialize(name, password)
      @id = generate_id
      @name = name
      @password_hash = hash password
    end

    def authenticate(password)
      @password_hash == password
    end

    private

    def generate_id
      SecureRandom.uuid
    end

    def hash(password)
      BCrypt::Password.create(password)
    end
  end

  class GuestUser
    def name
      'guest'
    end
  end
end
