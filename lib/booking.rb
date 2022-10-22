require 'active_record'
require 'pg'
require_relative 'user'

class Booking < ActiveRecord::Base
  def guest_name
    User.find(user_id).name
  end

  def guest_username
    User.find(user_id).username
  end

  def confirm
    Booking.where(space_id: space_id, date: date).where.not(user_id: user_id).each(&:destroy)
    update(is_booked: true)
  end

  def space_name
    Space.find(space_id).name
  end

  def space_description
    Space.find(space_id).description
  end

  def price_to_string
    Space.find(space_id).price_to_string
  end
end
