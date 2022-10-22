require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/user'
require_relative 'lib/booking'
require_relative 'lib/space'
require 'active_record'
require 'pg'
require 'date'
require 'cgi'

if ENV['DATABASE_URL'].nil?
  ActiveRecord::Base.establish_connection(
    adapter:  'postgresql',
    database: 'makersbnb_test'
  )
else
  ActiveRecord::Base.establish_connection()
end

class Application < Sinatra::Base
  configure do
    register Sinatra::Reloader
    also_reload 'lib/space'
    also_reload 'lib/user'
    also_reload 'lib/booking'
    enable :sessions
  end

  def self.escape_html_all_params(params)
    # this santises all inputs
    # included as a self method so it could be tested in RSpec
    params.each { |k, v| params[k] = CGI.escapeHTML(v) }
  end

  def invalid_date
    params[:date_availability_start] <= Date.today.to_s
  end

  def invalid_dates
    params[:date_availability_start] > params[:date_availability_end]
  end

  get '/' do
    @user_id = session[:user_id]
    erb(:index)
  end

  get '/login' do
    return erb(:login)
  end

  post '/login' do
    return status 400 if !session[:user_id].nil? || params[:email].nil? || params[:password].nil?
    Application.escape_html_all_params(params)
    email = params[:email]
    password = params[:password]
    user = User.find_by(email: email)
    if !user.nil?
      if user.decrypt_password == password
        session[:user_id] = user.id
        return erb(:login_success)
      end
    end
    redirect to '/login'
  end

  get '/logout' do
    session.delete(:user_id)
    erb(:logout)
  end

  get '/spaces' do
    @user_id = session[:user_id]
    @spaces = Space.all
    return erb(:spaces)
  end

  get '/spaces/:id' do
    return status 400 if params[:id].to_i.to_s != params[:id]
    @unavailable_date = params[:unavailable_date]
    @today = Time.now.strftime("%Y-%m-%d")
    Application.escape_html_all_params(params)
    @space_id = params[:id]
    @space = Space.find(params[:id])
    return erb(:spaces_id)
  end

  post '/spaces/:id' do
    return status 400 if params[:id].to_i.to_s != params[:id] || params[:date].nil?
    Application.escape_html_all_params(params)
    redirect to "/spaces/#{params[:id]}?unavailable_date=#{params[:date]}" if 
      !Booking.where(date: params[:date], is_booked: true).empty?
    Booking.create(
      user_id: session[:user_id],
      space_id: params[:id],
      date: params[:date],
      is_booked: false
    )
    @space_id = params[:id]
    return erb(:booking_request)
  end

  get '/manage-spaces/new' do
    Application.escape_html_all_params(params)
    @invalid_date = params[:invalid_date]
    @invalid_dates = params[:invalid_dates]
    @today = Time.now.strftime("%Y-%m-%d")
    @tomorrow = (Time.now + 86400).strftime("%Y-%m-%d")
    return erb(:manage_spaces_new)
  end

  post '/manage-spaces/new' do
    return status 400 if session[:user_id].nil? || params[:name].nil? ||
      params[:description].nil? || params[:price].nil? || params[:date_availability_start].nil? ||
      params[:date_availability_end].nil?
    Application.escape_html_all_params(params)
    redirect to '/manage-spaces/new?invalid_dates=true' if invalid_dates
    redirect to '/manage-spaces/new?invalid_date=true' if invalid_date     
    Space.create(
      name: params[:name],
      description: params[:description],
      price: params[:price],
      date_availability_start: params[:date_availability_start],
      date_availability_end: params[:date_availability_end],
      user_id: session[:user_id]
      )
      redirect to '/manage-spaces'
  end

  get '/manage-spaces' do
    @spaces = User.find(session[:user_id]).spaces
    return erb(:manage_spaces)
  end

  post '/manage-spaces/:booking_id' do
    return status 400 if params[:booking_id].to_i.to_s != params[:booking_id] ||
      params[:booking].nil?
    Application.escape_html_all_params(params)
    booking = params[:booking]
    Booking.find(params[:booking_id]).confirm if booking == 'confirm'
    Booking.find(params[:booking_id]).destroy if booking == 'decline'
    redirect to '/manage-spaces'
  end

  get '/manage-spaces/edit/:id' do
    return status 400 if params[:id].to_i.to_s != params[:id]
    Application.escape_html_all_params(params)
    @invalid_date = params[:invalid_date] == 'true'
    @invalid_dates = params[:invalid_dates] == 'true'
    @today = Time.now.strftime("%Y-%m-%d")
    @tomorrow = (Time.now + 86400).strftime("%Y-%m-%d")
    @space_id = params[:id]
    return erb(:manage_spaces_edit)
  end

  post '/manage-spaces/edit/:id' do
    return status 400 if params[:id].to_i.to_s != params[:id]
    Application.escape_html_all_params(params)
    Space.where(id: params[:id]).update_all(name: params[:name],
      description: params[:description],
      price: params[:price],
      date_availability_start: params[:date_availability_start],
      date_availability_end: params[:date_availability_end]
    )
    redirect to '/manage-spaces'
  end

  get '/sign-up/new' do
    erb(:sign_up_new)
  end

  post '/sign-up/new' do
    return status 400 if params[:name].nil? || params[:username].nil? ||
      params[:email].nil? || params[:password].nil?
    Application.escape_html_all_params(params)
    user = User.create(
      name: params[:name], 
      username: params[:username], 
      email: params[:email], 
      password: User.encrypt_password(params[:password])
    )
    @name = user.name
    session[:user_id] = user.id
    erb(:sign_up_new_success)
  end

  get '/requests' do
    Application.escape_html_all_params(params)
    @booking_requests = Booking.where(user_id: session[:user_id])
    erb(:requests)
  end

  post '/requests/cancel/:booking_id' do
    return status 400 if params[:booking_id].to_i.to_s != params[:booking_id] ||
      session[:user_id] != Booking.find(params[:booking_id]).user_id
    Application.escape_html_all_params(params)
    Booking.destroy(params[:booking_id])
    erb(:requests_cancel)
  end
end
