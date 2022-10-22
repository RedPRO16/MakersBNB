TRUNCATE TABLE users, spaces, bookings RESTART IDENTITY;

INSERT INTO users (name, username, email, password) VALUES
('John Isaac', 'JI2022', 'john@hotmail.com', '$2a$12$Ewl914TPTcEfBnaLV.Z.R.xtZYW3RmHfe/wNL/sjfJ4JcWDr/hb0u'),
('Daniel Roma', 'BeatTheHeat', 'danny@gmail.com', '$2a$12$bGuynR31kJ9zn8wdWomMl.cq/JbkW4lVqd3q7qtnPR8S3oeLlHg/W'),
('Marky Mark', 'FunkyB', 'marky@yahoo.com', '$2a$12$7rOVIce7sqCzT3e/vwlVB.AfQBti5sSAh0TOdVl7LHG0k7zT6R2qq'),
('Baby Yoda', 'mandoDisneyLover', 'yoda@starwars.com', '$2a$12$cnnLCimcWEiscQZAi9OfSOLr1rtj/88Bd1L9w86SPjec5JTlcTno.')
;

INSERT INTO spaces (name, description, price, date_availability_start, date_availability_end, user_id) VALUES
('Ballroom', 'Fancy ballroom in central', 50.00, '2022-06-01', '2023-06-01', 1),
('Nice house', 'Great views from lounge', 120.00, '2022-06-01', '2023-06-01', 1),
('Country cottage', 'Really amazing fields to walk through', 225.00, '2022-10-01', '2022-12-01', 2),
('Manor', 'Historic country estate', 500.00, '2022-06-01', '2023-12-01', 3),
('Spare room', 'Comfy bed', 15.00, '2022-02-15', '2022-11-01', 4),
('Village hall', 'Great space for meetings', 40.00, '2022-03-15', '2022-11-30', 2)
;

INSERT INTO bookings (user_id, space_id, date, is_booked) VALUES
(3, 1, '2022-10-01', FALSE),
(2, 1, '2022-10-01', FALSE),
(2, 3, '2022-10-05', FALSE),
(4, 5, '2022-10-30', FALSE)
;
