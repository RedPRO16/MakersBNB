require 'booking'

def reset_bookings_table
  seed_sql = File.read('spec/seeds/mixed_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe Booking do
  before(:each) do 
    reset_bookings_table
    ActiveRecord::Base.establish_connection(
      adapter:  'postgresql',
      database: 'makersbnb_test'
    )
  end

  it "returns the guest name" do
    name = Booking.first.guest_name
    expect(name).to eq "Marky Mark"
  end

  it "returns guest username" do
    username = Booking.first.guest_username
    expect(username).to eq "FunkyB"
  end

  it 'confirms a booking and deletes others for that date and space id' do
    Booking.first.confirm
    confirmed_booking = Space.first.bookings
    expect(confirmed_booking.length).to eq 1
    expect(confirmed_booking.first.user_id).to eq 3
    expect(confirmed_booking.first.is_booked).to eq true
  end

  it "gets a space's name" do
    expect(Booking.first.space_name).to eq 'Ballroom'
  end

  it "gets a space's description" do
    expect(Booking.first.space_description).to eq 'Fancy ballroom in central'
  end

  it "gets a space's price as a string" do
    expect(Booking.first.price_to_string).to eq "50.00"
  end
end


