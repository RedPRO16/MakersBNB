require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'

def reset_tables
  seed_sql = File.read('spec/seeds/mixed_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  before(:each) do
    reset_tables
    ActiveRecord::Base.establish_connection(

      adapter:  'postgresql',
      database: 'makersbnb_test'
    )
  end

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.


  context 'GET /' do
    it 'should get the homepage' do
      response = get('/')

      expect(response.status).to eq(200)
      expect(response.body).to include("Welcome to MakersBnB")
      expect(response.body).to include("<title>MakersBnB</title>")
    end
  end

  context 'GET /login' do
    it "returns form to log in" do
      response = get('/login')
      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Login here</h1>")
      expect(response.body).to include("Email address:")
      expect(response.body).to include("Password:")
    end
  end

  context "POST /login" do
    it 'log into account' do
      response = post('/login', email: "john@hotmail.com", password: "password123")

      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Successfully logged in</h1>")
    end
    it "does not log in when password is incorrect" do
      response = post('/login', email: "john@hotmail.com", password: "abc")

      expect(response.status).to eq 302
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/login'
    end
    it "does not log in when email does not exist" do
      response = post('/login', email: "uhuhuh@hotmail.com", password: "abc")

      expect(response.status).to eq 302
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/login'
    end

    it 'returns status 400 if user is already logged in' do
      post('/login', email: 'john@hotmail.com', password: 'password123')
      response = post('/login', email: 'john@hotmail.com', password: 'password123')
      expect(response.status).to eq 400
    end

    it 'returns status 400 if params are empty' do
      response = post('/login')
      expect(response.status).to eq 400
    end
  end

  context "GET /spaces" do
    it 'should return a list of all spaces' do
      response = get('/spaces')
      expect(response.status).to eq 200
      expect(response.body).to include("<h1>All Spaces</h1>")
    end

    it 'should only show booking requests link if logged in' do
      response = get('/spaces')
      expect(response.status).to eq 200
      expect(response.body).not_to include 'Booking requests'
      post('/login', email: 'john@hotmail.com', password: 'password123')
      response = get('/spaces')
      expect(response.status).to eq 200
      expect(response.body).to include 'Booking requests'
    end
  end

  context "GET /spaces/:id" do
    it 'should return the details of a space' do
      response = get('/spaces/1')

      expect(response.status).to eq 200
      expect(response.body).to include("Ballroom")
      expect(response.body).to include('Fancy ballroom in central')
      expect(response.body).to include('50.00')
      expect(response.body).to include('2022-06-01')
      expect(response.body).to include('2023-06-01')
      expect(response.body).to include('Request to book')
    end

    it 'returns status 400 if :id is not an integer' do
      response = get('/spaces/string')
      expect(response.status).to eq 400
    end

    it "it says the minimum date must be today's date" do
      post('/login', email: 'john@hotmail.com', password: 'password123')
      response = get('/spaces/1')

      expect(response.status).to eq 200
      expect(response.body).to include "min=\"#{Time.now.strftime("%Y-%m-%d")}\""
    end

    it "it says the date is unavailable if it's already been confirmed" do
      Booking.create(user_id: 2, space_id: 3, date: "2022-12-31", is_booked: true)
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = get('/spaces/1', unavailable_date: "2022-12-31")

      expect(response.status).to eq 200
      expect(response.body).to include "2022-12-31 is unavailable"
    end
  end

  context "POST /spaces/:id" do
    it "Send a booking request for space id 1" do
      post('/login', email: 'john@hotmail.com', password: 'password123')
      response = post('/spaces/1', date: "2022-08-17")

      expect(response.status).to eq 200
      expect(response.body).to include("<h1>Your request has been sent for approval</h1>")
      expect(Booking.last.user_id).to eq 1
      expect(Booking.last.space_id).to eq 1
      expect(Booking.last.date.to_s).to eq "2022-08-17"
      expect(Booking.last.is_booked).to eq false
    end
    it 'returns status 400 if :id is not an integer' do
      post('/login', email: 'john@hotmail.com', password: 'password123')
      response = post('/spaces/string')
      expect(response.status).to eq 400
    end

    it 'returns status 400 if params are empty' do
      post('/login', email: 'john@hotmail.com', password: 'password123')
      response = post('/spaces/1')
      expect(response.status).to eq 400
    end

    it "redirects with an unavailable_date parmaeter if date has already been booked" do

      Booking.create(user_id: 2, space_id: 3, date: "2022-12-31", is_booked: true)
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = post('/spaces/1', date: "2022-12-31")

      expect(response.status).to eq 302
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/spaces/1?unavailable_date=2022-12-31'
    end
  end

  context "GET /manage-spaces/new" do
    it "returns form to create a space" do
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = get('/manage-spaces/new')

      expect(response.status).to eq 200
      expect(response.body).to include "Name:"
      expect(response.body).to include "Description:"
      expect(response.body).to include "Price:"
      expect(response.body).to include "Date from:"
      expect(response.body).to include "Date to:"
    end

    it "says we've selected a date in the past" do
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = get('/manage-spaces/new', invalid_date: "true")
      
      expect(response.status).to eq 200
      expect(response.body).to include "Add your space here"
      expect(response.body).to include "Please choose a date in the present or future."
    end

    it "says we need to select a start date that's before the end date" do
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = get('/manage-spaces/new', invalid_dates: "true")

      expect(response.status).to eq 200
      expect(response.body).to include "Please enter a start date that begins before the end date"
    end
  end

  context 'POST /manage-spaces/:booking_id' do
    it "confirms a booking" do
      post("/login", email: 'john@hotmail.com', password: 'password123')
      response = post("/manage-spaces/1", booking: 'confirm')
      expect(response.status).to eq 302
      space_bookings = Space.find(1).bookings
      expect(space_bookings.length).to eq 1
      expect(space_bookings.first.id).to eq 1
      expect(space_bookings.first.is_booked).to eq true
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/manage-spaces'
    end

    it "declines a booking" do
      post("/login", email: 'john@hotmail.com', password: 'password123')
      response = post("/manage-spaces/1", booking: 'decline')
      expect(response.status).to eq 302
      space_bookings = Space.find(1).bookings
      expect(space_bookings.length).to eq 1
      expect(space_bookings.first.id).to eq 2
      expect(space_bookings.first.is_booked).to eq false
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/manage-spaces'
    end
    
    it 'returns status 400 if params are empty' do
      post("/login", email: 'john@hotmail.com', password: 'password123')
      response = post('/manage-spaces/1')
      expect(response.status).to eq 400
    end

    it 'returns status 400 if :booking_id is not an integer' do
      post("/login", email: 'john@hotmail.com', password: 'password123')
      response = post('/manage-spaces/string')
      expect(response.status).to eq 400
    end
  end

  context "GET /manage-spaces" do
    it "should list the logged in user's spaces" do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = get('/manage-spaces')
      expect(response.status).to eq 200
      expect(response.body).to include 'Ballroom'
      expect(response.body).to include 'Fancy ballroom in central'
      expect(response.body).to include '£50.00 per night'
      expect(response.body).to include 'Available from 2022-06-01'
      expect(response.body).to include 'Available to 2023-06-01'
      expect(response.body).to include 'Booking request from Marky Mark, @FunkyB'
      expect(response.body).to include '2022-10-01'
      expect(response.body).to include 'Confirm'
      expect(response.body).to include 'Decline'
      expect(response.body).to include 'Booking request from Daniel Roma, @BeatTheHeat'
      expect(response.body).to include '2022-10-01'
      expect(response.body).to include 'Nice house'
      expect(response.body).to include 'Great views from lounge'
      expect(response.body).to include '£120.00 per night'
      expect(response.body).to include 'Available from 2022-06-01'
      expect(response.body).to include 'Available to 2023-06-01'
    end

    it "should not give a choice box if already confirmed" do
      Booking.first.confirm
      post("/login", email: "john@hotmail.com", password: "password123")
      response = get('/manage-spaces')
      expect(response.status).to eq 200
      expect(response.body).to include 'Booking request from Marky Mark, @FunkyB'
      expect(response.body).to include '2022-10-01'
      expect(response.body).not_to include '<form action="/manage-spaces/'
      expect(response.body).to include 'This booking has been confirmed'
    end
  end

  context "POST /manage-spaces/new" do
    it "creates a new space" do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = post("/manage-spaces/new", name: 'house', description: 'description', price: 50.0, date_availability_start: '2022-08-22', date_availability_end: '2022-08-23')
      expect(response.status).to eq 302
      space = Space.last
      expect(Space.all.length).to eq 7
      expect(space.id).to eq 7
      expect(space.name).to eq 'house'
      expect(space.description).to eq 'description'
      expect(space.price).to eq 50.0
      expect(space.date_availability_start.to_s).to eq '2022-08-22'
      expect(space.date_availability_end.to_s).to eq '2022-08-23'
      expect(space.user_id).to eq 1
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/manage-spaces'
    end

    it "should redirect with an error message when given a past date" do 
      post("/login", email: "john@hotmail.com", password: "password123")
      response = post(
        "/manage-spaces/new",
        name: 'house',
        description: 'description',
        price: 50.0,
        date_availability_start: '2021-08-17',
        date_availability_end: '2022-08-18'
      )
      expect(response.status).to eq 302
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/manage-spaces/new?invalid_date=true'
    end

    it "redirects if start date is after end date" do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = post(
        "/manage-spaces/new",
        name: 'house',
        description: 'description',
        price: 50.0,
        date_availability_start: '2022-08-21',
        date_availability_end: '2022-08-20'
      )
      expect(response.status).to eq 302
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.url).to include '/manage-spaces/new?invalid_dates=true'
    end

    it 'returns status 400 if user not logged in' do
      response = post(
        "/manage-spaces/new",
        name: 'house',
        description: 'description',
        price: 50.0,
        date_availability_start: '2022-08-21',
        date_availability_end: '2022-08-20'
      )
      expect(response.status).to eq 400
    end

    it 'returns status 400 if params are empty' do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = post("/manage-spaces/new")
      expect(response.status).to eq 400
    end
  end

  context 'GET /logout' do
    it 'logs the user out' do
      post("/login",
        email: "john@hotmail.com", password: "password123")
      response = get("/logout")
      expect(response.status).to eq 200
      expect(response.body).to include 'You have successfully logged off'
      expect(response.body).to include 'Return to homepage'
    end
  end
  
  context "GET /manage-spaces/edit/:id" do
    it "return the edit form for space id 1" do
      post("/login", email: "john@hotmail.com", password: "password123")

      response = get('/manage-spaces/edit/1')

      expect(response.status).to eq 200
      expect(response.body).to include("Name:")
      expect(response.body).to include("Description:")
      expect(response.body).to include("Price:")
      expect(response.body).to include("Date from:")
      expect(response.body).to include("Date to:")
    end

    it 'returns status 400 if :id is not an integer' do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = get('/manage-spaces/edit/string')
      expect(response.status).to eq 400
    end

    it "says we've selected a date in the past" do
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = get('/manage-spaces/edit/1', invalid_date: true)
      
      expect(response.status).to eq 200
      expect(response.body).to include "Please choose a date in the present or future."
    end

    it "says we need to choose a start date that is before the end date" do
      post('/login', email: 'john@hotmail.com', password: 'password123')

      response = get('/manage-spaces/edit/1', invalid_dates: "true")

      expect(response.status).to eq 200
      expect(response.body).to include "Please enter a start date that begins before the end date"
    end
  end

  context "POST /manage-spaces/edit/:id" do
    it "updates the information of space id 1" do
      post("/login", email: "john@hotmail.com", password: "password123")
      
      response= post('/manage-spaces/edit/1', name: "Ballroom hall", description: "Fancy ballroom in the city", price: 75.00, date_availability_start: "2022-06-01", date_availability_end: "2023-06-01")
      
      space = Space.find(1)
      expect(space.name).to eq 'Ballroom hall'
      expect(space.description).to eq 'Fancy ballroom in the city'
      expect(space.price).to eq 75.00
      expect(space.date_availability_start.to_s).to eq '2022-06-01'
      expect(space.date_availability_end.to_s).to eq '2023-06-01'
      expect(space.user_id).to eq 1
    end

    it 'returns status 400 if :id is not an integer' do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = post('/manage-spaces/edit/string')
      expect(response.status).to eq 400
    end
  end
  
  context "GET /sign-up/new" do
    it "loads a sign up page" do
      response = get('/sign-up/new')
      expect(response.status).to eq 200
      expect(response.body).to include 'Name:'
      expect(response.body).to include 'Username:'
      expect(response.body).to include 'Email:'
      expect(response.body).to include 'Password:'
      expect(response.body).to include 'Submit'
      expect(response.body).to include 'Back'
    end
  end
  context "POST /sign-up/new" do
    it "created new user and sign them in " do
      response = post(
        '/sign-up/new',
        name: 'name',
        username: 'username',
        email: 'email',
        password: 'password'
      )
      expect(response.status).to eq 200
      expect(User.all.length).to eq 5
      expect(User.last.name).to eq 'name'
      expect(User.last.username).to eq 'username'
      expect(User.last.email).to eq 'email'
      expect(User.last.decrypt_password).to eq 'password'
      expect(User.last.id).to eq 5
      expect(response.body).to include 'Welcome name to Makers BnB'
      expect(response.body).to include 'You are now logged in'
      expect(response.body).to include 'Return to home page'
    end

    it 'return status 400 if params are empty' do
      response = post('/sign-up/new')
      expect(response.status).to eq 400
    end
  end
  
  context 'GET /requests' do
    it "lists the user's booking requests" do
      post("/login", email: "danny@gmail.com", password: "admin")
      response = get('/requests')
      expect(response.status).to eq 200
      expect(response.body).to include 'Booking Requests'
      expect(response.body).to include 'Ballroom'
      expect(response.body).to include 'Fancy ballroom in central'
      expect(response.body).to include '£50.00 per night'
      expect(response.body).to include 'Requesting to book on 2022-10-01'
      expect(response.body).to include 'Booking awaiting confirmation'
      expect(response.body).to include 'Cancel booking'
      expect(response.body).to include 'Country cottage'
      expect(response.body).to include 'Really amazing fields to walk through'
      expect(response.body).to include '£225.00 per night'
      expect(response.body).to include 'Requesting to book on 2022-10-05'
      expect(response.body).to include 'Booking awaiting confirmation'
      expect(response.body).to include 'Cancel booking'
      expect(response.body).to include 'Back'
    end

    it "says a user's booking has been confirmed" do
      Booking.create(
        user_id: 1,
        space_id: 4,
        date: '2022-10-05',
        is_booked: true
      )
      post("/login", email: "john@hotmail.com", password: "password123")
      response = get('/requests')
      expect(response.status).to eq 200
      expect(response.body).to include 'Booking Requests'
      expect(response.body).to include 'Manor'
      expect(response.body).to include 'Historic country estate'
      expect(response.body).to include '£500.00 per night'
      expect(response.body).to include 'Requesting to book on 2022-10-05'
      expect(response.body).to include 'This booking has been confirmed!'
      expect(response.body).to include 'Cancel booking'
    end
  end

  context 'POST /requests/cancel/:booking_id' do
    it 'cancels a booking' do
      post("/login", email: "danny@gmail.com", password: "admin")
      response = post('/requests/cancel/2')
      expect(response.status).to eq 200
      expect(Booking.find_by(id: 2)).to eq nil
      expect(response.body).to include 'This booking has been cancelled'
      expect(response.body).to include 'Back'
    end

    it 'returns status 400 if :booking_id is not an integer' do
      post("/login", email: "danny@gmail.com", password: "admin")
      response = post('/requests/cancel/string')
      expect(response.status).to eq 400
    end

    it 'returns status 400 if a user is not logged in' do
      response = post('/requests/cancel/2')
      expect(response.status).to eq 400
    end

    it 'returns status 400 if the correct user is not logged in' do
      post("/login", email: "john@hotmail.com", password: "password123")
      response = post('/requests/cancel/2')
      expect(response.status).to eq 400
    end
  end

  context 'escape_html_all_params' do
    it 'santises all params inputs' do
      params = { "username" => "JI2<><>022", "password" => "passw<><>ord123" }
      result = { "password" => "passw&lt;&gt;&lt;&gt;ord123", "username" => "JI2&lt;&gt;&lt;&gt;022" }
      expect(Application.escape_html_all_params(params)).to eq result
    end
  end
end
