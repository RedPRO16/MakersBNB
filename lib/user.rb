require 'active_record'
require 'pg'
require_relative 'space'
require 'bcrypt'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  database: 'makersbnb_test'
)

class User < ActiveRecord::Base
  include BCrypt
  def spaces
    Space.where(user_id: id)
  end

  def decrypt_password
    Password.new(password)
  end

  def self.encrypt_password(new_password)
    Password.create(new_password)
  end
end

# p User.encrypt_password("jediking")