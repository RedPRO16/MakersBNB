TRUNCATE TABLE users, spaces, bookings RESTART IDENTITY;

INSERT INTO users (name, username, email, password) VALUES
('John Isaac', 'JI2022', 'john@hotmail.com', '$2a$12$Ewl914TPTcEfBnaLV.Z.R.xtZYW3RmHfe/wNL/sjfJ4JcWDr/hb0u'),
('Daniel Roma', 'BeatTheHeat', 'danny@gmail.com', '$2a$12$bGuynR31kJ9zn8wdWomMl.cq/JbkW4lVqd3q7qtnPR8S3oeLlHg/W'),
('Marky Mark', 'FunkyB', 'marky@yahoo.com', '$2a$12$7rOVIce7sqCzT3e/vwlVB.AfQBti5sSAh0TOdVl7LHG0k7zT6R2qq'),
('Baby Yoda', 'mandoDisneyLover', 'yoda@starwars.com', '$2a$12$cnnLCimcWEiscQZAi9OfSOLr1rtj/88Bd1L9w86SPjec5JTlcTno.')
;
