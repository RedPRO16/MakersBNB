# MakersBnB Project Seed

This repo contains the seed codebase for the MakersBnB project in Ruby (using Sinatra and RSpec).

Someone in your team should fork this seed repo to their Github account. Everyone in the team should then clone this fork to their local machine to work on it.

## Setup

```bash
# Install gems
bundle install

# Run the tests
rspec

# Run the server (better to do this in a separate terminal).
rackup
```


# MakersBnB

## Team Fire 🔥

Our team challenge was to develop a BnB application over the period of 1 week starting with a Ruby / Sinatra framework.

We used notion to capture the [project specification](design/team-fire-spec.md) and create [user stories](design/user-stories.md). We developed the application using agile methodology and used Trello for our tickets.

# User stories

## 🔥 Sprint 1

*Users should be able to name their space, provide a short description of the space, and a price per night.*

* As a user/owner I want to list my air bnb for hire
* As a user/owner I want to name my listing
* As a user/owner I want a description for my listing
* As a user/owner I want to list the price per night
* As a user/renter I want to see the listing information

*Users should be able to offer a range of dates where their space is available.*

* As a user/owner I want to add future dates when my air bnb is available
* As a user/renter I want to see future dates when the listing is available
* Get ‘/ listing/id’ for renter to see listing details
* Get / listing/id/add_dates to open form to add available dates 
* Post / listing/id Post the form contents

## 🔥 Sprint 2

*As a renter I can request to hire a place for one night.*

*As an owner I can approve a request from a renter.*

* Nights for which a space has already been booked should not be available for users to book that space.

*As a renter, I can’t book a place which has already been rented for the night in question.*

* Once its booked its removed from available dates
* Until a user has confirmed a booking request, that space can still be booked for that night

*As a renter, I can request to book a place on a night with existing unconfirmed booking(s).*

*As an owner, I can review multiple booking requests for one location-night before accepting one of them.*

* Space is only removed from available once confirmed

## 🔥 Project specification

We would like a web application that allows users to list spaces they have available, and to hire spaces for the night.

## Headline specifications

- Any signed-up user can list a new space.
    - Seed with a list of users (2 or 3)
- Users can list multiple spaces.
    - Show places for each user
- Users should be able to name their space, provide a short description of the space, and a price per night.
    - Place name, description and price (future feature image? )
- Users should be able to offer a range of dates where their space is available.
    
    For a given space - the available dates are listed
    
- Any signed-up user can request to hire any space for one night, and this should be approved by the user that owns that space.
    
      must be signed up to request, requests must be approved, for one night bookings 
    
- Nights for which a space has already been booked should not be available for users to book that space.
    - once its booked its removed from available dates
- Until a user has confirmed a booking request, that space can still be booked for that night.
    - space is only removed from available once confirmed

## Nice-to-haves

- Users should receive an email whenever one of the following happens:
- They sign up
- They create a space
- They update a space
- A user requests to book their space
- They confirm a request
- They request to book a space
- Their request to book a space is confirmed
- Their request to book a space is denied
- Users should receive a text message to a provided number whenever one of the following happens:
- A user requests to book their space
- Their request to book a space is confirmed
- Their request to book a space is denied
- A ‘chat’ functionality once a space has been booked, allowing users whose space-booking request has been confirmed to chat with the user that owns that space
- Basic payment implementation though Stripe.

## Get Started

### Install

```bash
# Install gems
bundle install

# Install postgresql.
$ brew install postgresql

# (...)

# Run this after the installation
# to start the postgresql software
# in the background.
$ brew services start postgresql

# You should get the following output:
==> Successfully started `postgresql` (label: homebrew.mxcl.postgresql)
```

### Run

This application uses rack as its server.

```bash
# Run the server (better to do this in a separate terminal).
rackup
```

Now go to **http://localhost:9292/** in your web browser

### Testing

Use RSpec to run unit tests and integration tests as used during development.

```bash
# Run the tests
rspec
```

## Tech

* Ruby
* Sinatra
* PostgreSQL
* BCrypt
* Rack
* RSpec
