TRUNCATE TABLE users, spaces, bookings RESTART IDENTITY;

INSERT INTO bookings (user_id, space_id, date, is_booked) VALUES
(3, 1, '2022-10-01', FALSE),
(2, 1, '2022-10-01', FALSE),
(2, 3, '2022-10-05', FALSE),
(4, 5, '2022-10-30', FALSE)
;