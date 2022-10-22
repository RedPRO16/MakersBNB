CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name text,
  username text,
  email text,
  password text
);

CREATE TABLE spaces (
  id SERIAL PRIMARY KEY,
  name text,
  description text,
  price decimal(10,2),
  date_availability_start date,
  date_availability_end date,
-- The foreign key name is always {other_table_singular}_id
  user_id int,
  constraint fk_user foreign key(user_id)
    references users(id)
    on delete cascade
);

CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  user_id int,
  space_id int,
  constraint fk_user foreign key(user_id) references users(id) on delete cascade,
  constraint fk_space foreign key(space_id) references spaces(id) on delete cascade,
  date date,
  is_booked boolean
);
