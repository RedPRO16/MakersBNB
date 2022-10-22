require 'space'

def reset_spaces_table
  seed_sql = File.read('spec/seeds/mixed_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe Space do
  before(:each) do 
    reset_spaces_table
    ActiveRecord::Base.establish_connection(
      adapter:  'postgresql',
      database: 'makersbnb_test'
    )
  end

  it "returns the host name" do
    name = Space.first.host_name
    expect(name).to eq "John Isaac"
  end

  it "returns host username" do
    username = Space.first.host_username
    expect(username).to eq "JI2022"
  end

  it "finds bookings" do
    bookings = Space.first.bookings
    expect(bookings.length).to eq 2
  end

  it "returns price as two digits decimal string" do
    expect(Space.first.price_to_string).to eq '50.00'
  end
end