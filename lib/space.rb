require 'active_record'
require 'pg'
require_relative 'user'
require_relative 'booking'

ActiveRecord::Base.establish_connection(
      adapter:  'postgresql',
      database: 'makersbnb_test'
    )
class Space < ActiveRecord::Base
  def host_name
    User.find(user_id).name
  end

  def host_username
    User.find(user_id).username
  end

  def bookings
    Booking.where(space_id: id).sort_by(&:date)
  end

  def price_to_string
    price_split = price.to_s.split('.')
    price_split[1] += "0" if price_split[1].length == 1
    price_split.join('.') 
  end
end



