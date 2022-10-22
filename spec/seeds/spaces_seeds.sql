TRUNCATE TABLE users, spaces RESTART IDENTITY; -- replace with your own table name.

INSERT INTO spaces (name, description, price, date_availability_start, date_availability_end, user_id) VALUES
('Ballroom', 'Fancy ballroom in central', 50.00, '2022-06-01', '2023-06-01', 1),
('Nice house', 'Great views from lounge', 120.00, '2022-06-01', '2023-06-01', 1),
('Country cottage', 'Really amazing fields to walk through', 225.00, '2022-10-01', '2022-12-01', 2),
('Manor', 'Historic country estate', 500.00, '2022-06-01', '2023-12-01', 3),
('Spare room', 'Comfy bed', 15.00, '2022-02-15', '2022-11-01', 4),
('Village hall', 'Great space for meetings', 40.00, '2022-03-15', '2022-11-30', 2)
;