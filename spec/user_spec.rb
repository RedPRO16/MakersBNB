require 'user'
require 'space'

def reset_tables
  seed_sql = File.read('spec/seeds/mixed_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe User do
  before(:each) do 
    reset_tables
    ActiveRecord::Base.establish_connection(
      adapter:  'postgresql',
      database: 'makersbnb_test'
    )
  end

  it "returns the users spaces" do
    spaces = User.first.spaces
    expect(spaces.length).to eq 2
  end

  it 'decrypts the password' do
    User.create(name: 'name', username: 'username', email: 'email', password: User.encrypt_password("password"))
    expect(User.last.decrypt_password).to eq "password"
  end
end