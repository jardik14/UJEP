START TRANSACTION;

-- Table: Animal
CREATE TABLE Animal (
    animal_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age SMALLINT NOT NULL,
    species VARCHAR(255) NOT NULL
);

-- Table: Pavilion
CREATE TABLE Pavilion (
    pavilion_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    est_date DATE NOT NULL
);

-- Table: Employee
CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    manager_id INT,
    pavilion_id INT,  -- Foreign key to Pavilion table
    role_name VARCHAR(255),  -- Attribute for the role name
    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (pavilion_id) REFERENCES Pavilion(pavilion_id)
);


-- Table: Contract
CREATE TABLE Contract (
    contract_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    salary INTEGER NOT NULL,
    contract_start DATE NOT NULL,
    contract_end DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- Table: Feeding
CREATE TABLE Feeding (
    feeding_id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    food VARCHAR(255) NOT NULL,
    animal_id INT,
    employee_id INT,
    FOREIGN KEY (animal_id) REFERENCES Animal(animal_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- Relationship between Animal and Pavilion (Animal lives in Pavilion)
ALTER TABLE Animal
ADD COLUMN pavilion_id INT,
ADD FOREIGN KEY (pavilion_id) REFERENCES Pavilion(pavilion_id);

CREATE TABLE Visitor (
    visitor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    visit_date DATE NOT NULL,
    ticket_type VARCHAR(20) CHECK (ticket_type IN ('adult', 'child', 'senior')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE visitor_feedback (
    feedback_id SERIAL PRIMARY KEY,
    visitor_id INT NOT NULL,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comments TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    FOREIGN KEY (visitor_id) REFERENCES Visitor(visitor_id)
);

CREATE TABLE EmployeeAuditLog (
    log_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    old_name VARCHAR(255),
    old_surname VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(255) NOT NULL
);


INSERT INTO Pavilion (name, est_date) VALUES
('Savannah', '2005-03-15'),
('Rainforest', '1998-07-22'),
('Arctic', '2010-11-30'),
('Desert', '2000-05-10'),
('Aquatic', '2015-06-25');

-- Insert 20 random animals and assign them to a pavilion
INSERT INTO Animal (name, age, species, pavilion_id) VALUES
('Leo', 4, 'Lion', 1),
('Ella', 2, 'Elephant', 2),
('Milo', 3, 'Giraffe', 1),
('Zara', 5, 'Zebra', 1),
('Max', 7, 'Tiger', 1),
('Lola', 1, 'Penguin', 3),
('Oscar', 6, 'Kangaroo', 4),
('Bella', 8, 'Chimpanzee', 2),
('Rocky', 4, 'Rhinoceros', 1),
('Daisy', 2, 'Flamingo', 5),
('Simba', 5, 'Lion', 1),
('Nina', 3, 'Panther', 2),
('Charlie', 2, 'Koala', 4),
('Sasha', 6, 'Polar Bear', 3),
('Rex', 9, 'Crocodile', 5),
('Luna', 1, 'Leopard', 2),
('Toby', 4, 'Wolf', 4),
('Maggie', 7, 'Elephant', 2),
('Ruby', 5, 'Gorilla', 2),
('Jake', 3, 'Hyena', 1);

INSERT INTO Employee (name, surname, manager_id, pavilion_id, role_name) VALUES
('Albert', 'Davies', NULL, NULL, 'Director'),
('John', 'Rodriguez', 1, 1, 'Zookeeper'),
('Linda', 'Mercer', 1, 5, 'Veterinarian'),
('Jamie', 'Hall', 2, 2, 'Zookeeper'),
('Margaret', 'Owens', 3, NULL, 'Researcher'),
('Julie', 'Munoz', 3, 3, 'Zookeeper'),
('Randy', 'Miller', 8, NULL, 'Maintenance'),
('Adam', 'Kirk', 3, 3, 'Assistant'),
('Anthony', 'Duran', 2, 2, 'Zookeeper'),
('Krista', 'Garrett', 8, NULL, 'Cashier'),
('Kenneth', 'Alvarado', 10, 2, 'Tour Guide'),
('Raymond', 'Chang', 2, 2, 'Zookeeper'),
('Linda', 'Miller', 3, 5, 'Researcher'),
('Jason', 'Cohen', 3, 3, 'Zookeeper'),
('Angelica', 'Richards', 11, NULL, 'Cashier'),
('Jodi', 'Anderson', 15, 3, 'Veterinarian'),
('Thomas', 'Smith', 16, 2, 'Zookeeper'),
('Michelle', 'Chaney', 11, 1, 'Zookeeper'),
('Jason', 'Walton', 8, NULL, 'Maintenance'),
('Heidi', 'Ortega', 18, 3, 'Veterinarian');


INSERT INTO Contract (employee_id, salary, contract_start, contract_end) VALUES
(1, 50000, '2021-01-01', '2023-01-01'),
(2, 55000, '2021-05-15', '2024-05-15'),
(3, 60000, '2022-03-20', '2025-03-20'),
(4, 48000, '2020-11-10', '2023-11-10'),
(5, 72000, '2023-01-05', '2024-01-05'),
(6, 51000, '2022-08-01', '2023-08-01'),
(7, 53000, '2023-02-14', '2026-02-14'),
(8, 59000, '2019-04-22', '2022-04-22'),
(9, 62000, '2020-10-30', '2023-10-30'),
(10, 67000, '2022-07-15', '2025-07-15'),
(11, 50000, '2021-06-01', '2024-06-01'),
(12, 55000, '2020-09-09', '2023-09-09'),
(13, 72000, '2022-12-01', '2025-12-01'),
(14, 49000, '2018-02-18', '2021-02-18'),
(15, 68000, '2023-01-20', '2026-01-20'),
(16, 53000, '2019-05-15', '2022-05-15'),
(17, 61000, '2021-03-03', '2024-03-03'),
(18, 55000, '2019-07-01', '2022-07-01'),
(19, 50000, '2022-10-10', '2023-10-10'),
(20, 62000, '2020-06-25', '2023-06-25'),
(1, 57000, '2023-01-02', '2026-09-01');

INSERT INTO Feeding (date, food, animal_id, employee_id) VALUES
('2024-09-01', 'Meat', 1, 1),
('2024-09-02', 'Grass', 2, 2),
('2024-09-03', 'Leaves', 3, 3),
('2024-09-04', 'Fruits', 4, 4),
('2024-09-05', 'Meat', 5, 5),
('2024-09-06', 'Fish', 6, 6),
('2024-09-07', 'Grass', 7, 7),
('2024-09-08', 'Fruits', 8, 8),
('2024-09-09', 'Meat', 9, 9),
('2024-09-10', 'Fish', 10, 10),
('2024-09-11', 'Meat', 1, 1),
('2024-09-12', 'Grass', 2, 2),
('2024-09-13', 'Leaves', 3, 3),
('2024-09-14', 'Fruits', 4, 4),
('2024-09-15', 'Meat', 5, 5),
('2024-09-16', 'Fish', 6, 6),
('2024-09-17', 'Grass', 7, 7),
('2024-09-18', 'Fruits', 8, 8),
('2024-09-19', 'Meat', 9, 9),
('2024-09-20', 'Fish', 10, 10),
('2024-09-21', 'Meat', 1, 1),
('2024-09-22', 'Grass', 2, 2),
('2024-09-23', 'Leaves', 3, 3),
('2024-09-24', 'Fruits', 4, 4),
('2024-09-25', 'Meat', 5, 5),
('2024-09-26', 'Fish', 6, 6),
('2024-09-27', 'Grass', 7, 7),
('2024-09-28', 'Fruits', 8, 8),
('2024-09-29', 'Meat', 9, 9),
('2024-09-30', 'Fish', 10, 10),
('2024-08-01', 'Meat', 1, 1),
('2024-08-02', 'Grass', 2, 2),
('2024-08-03', 'Leaves', 3, 3),
('2024-08-04', 'Fruits', 4, 4),
('2024-08-05', 'Meat', 5, 5),
('2024-08-06', 'Fish', 6, 6),
('2024-08-07', 'Grass', 7, 7),
('2024-08-08', 'Fruits', 8, 8),
('2024-08-09', 'Meat', 9, 9),
('2024-08-10', 'Fish', 10, 10),
('2024-08-11', 'Meat', 1, 1),
('2024-08-12', 'Grass', 2, 2),
('2024-08-13', 'Leaves', 3, 3),
('2024-08-14', 'Fruits', 4, 4),
('2024-08-15', 'Meat', 5, 5),
('2024-08-16', 'Fish', 6, 6),
('2024-08-17', 'Grass', 7, 7),
('2024-08-18', 'Fruits', 8, 8),
('2024-08-19', 'Meat', 9, 9),
('2024-08-20', 'Fish', 10, 10),
('2024-08-21', 'Meat', 1, 1),
('2024-08-22', 'Grass', 2, 2),
('2024-08-23', 'Leaves', 3, 3),
('2024-08-24', 'Fruits', 4, 4),
('2024-08-25', 'Meat', 5, 5),
('2024-08-26', 'Fish', 6, 6),
('2024-08-27', 'Grass', 7, 7),
('2024-08-28', 'Fruits', 8, 8),
('2024-08-29', 'Meat', 9, 9),
('2024-08-30', 'Fish', 10, 10),
('2024-07-01', 'Meat', 1, 1),
('2024-07-02', 'Grass', 2, 2),
('2024-07-03', 'Leaves', 3, 3),
('2024-07-04', 'Fruits', 4, 4),
('2024-07-05', 'Meat', 5, 5),
('2024-07-06', 'Fish', 6, 6),
('2024-07-07', 'Grass', 7, 7),
('2024-07-08', 'Fruits', 8, 8),
('2024-07-09', 'Meat', 9, 9),
('2024-07-10', 'Fish', 10, 10),
('2024-07-11', 'Meat', 1, 1),
('2024-07-12', 'Grass', 2, 2),
('2024-07-13', 'Leaves', 3, 3),
('2024-07-14', 'Fruits', 4, 4),
('2024-07-15', 'Meat', 5, 5),
('2024-07-16', 'Fish', 6, 6),
('2024-07-17', 'Grass', 7, 7),
('2024-07-18', 'Fruits', 8, 8),
('2024-07-19', 'Meat', 9, 9),
('2024-07-20', 'Fish', 10, 10),
('2024-07-21', 'Meat', 1, 1),
('2024-07-22', 'Grass', 2, 2),
('2024-07-23', 'Leaves', 3, 3),
('2024-07-24', 'Fruits', 4, 4),
('2024-07-25', 'Meat', 5, 5),
('2024-07-26', 'Fish', 6, 6),
('2024-07-27', 'Grass', 7, 7),
('2024-07-28', 'Fruits', 8, 8),
('2024-07-29', 'Meat', 9, 9),
('2024-07-30', 'Fish', 10, 10);

INSERT INTO Visitor (first_name, last_name, email, visit_date, ticket_type) VALUES
('Rachel', 'Campbell', 'mariawilliams@kelley.info', '2024-03-13', 'adult'),
('Debra', 'Hansen', 'michael11@gallagher-pena.com', '2024-06-04', 'child'),
('Michelle', 'Ortiz', 'caitlinthomas@hotmail.com', '2023-10-22', 'senior'),
('Brian', 'Thomas', 'stacey14@meza-robles.biz', '2023-12-26', 'senior'),
('Roger', 'Norton', 'rebecca95@taylor.com', '2024-01-20', 'adult'),
('William', 'Jones', 'paulkemp@gmail.com', '2024-05-30', 'adult'),
('Jean', 'Zamora', 'mindypennington@gmail.com', '2024-06-10', 'adult'),
('Stephanie', 'Reilly', 'jacobskenneth@gmail.com', '2024-10-05', 'child'),
('Robert', 'Mooney', 'brian49@fry-jones.com', '2024-09-10', 'adult'),
('Annette', 'Curtis', 'meltonsusan@hotmail.com', '2024-02-04', 'adult'),
('Kathryn', 'Ayers', 'tsutton@hotmail.com', '2024-05-30', 'child'),
('Sara', 'Carpenter', 'nvega@smith.com', '2024-10-08', 'senior'),
('Amy', 'Miller', 'jenniferrice@bray.com', '2024-04-18', 'adult'),
('April', 'Nelson', 'paulaoliver@williams.com', '2024-03-24', 'child'),
('Sherry', 'White', 'amanda07@reid.info', '2024-01-24', 'adult'),
('Carla', 'Morrison', 'ychen@thompson.com', '2024-05-29', 'senior'),
('Christina', 'Huang', 'zcook@olson.org', '2023-12-14', 'adult'),
('Jennifer', 'Lawson', 'jeremysanchez@patterson-cohen.org', '2024-07-27', 'adult'),
('Vanessa', 'Garner', 'colin37@holmes-hernandez.info', '2024-03-09', 'senior'),
('Chad', 'Brown', 'luispotter@villa.net', '2024-09-18', 'adult'),
('Alexis', 'Grant', 'yevans@gmail.com', '2023-11-09', 'adult'),
('David', 'Bell', 'walljoseph@taylor.info', '2024-08-03', 'adult'),
('Cassandra', 'Mann', 'goodwintheresa@gmail.com', '2024-08-04', 'child'),
('Pamela', 'Williams', 'krowe@robinson-clark.net', '2023-11-15', 'child'),
('Daniel', 'Flores', 'hannahfuller@brooks.com', '2024-03-02', 'adult'),
('Diane', 'Gomez', 'tiffany18@yahoo.com', '2024-03-04', 'senior'),
('David', 'Gonzalez', 'margaret15@compton.com', '2023-12-27', 'child'),
('Brian', 'Hayes', 'angela81@gmail.com', '2024-09-19', 'child'),
('Kevin', 'Johnson', 'rbarton@gmail.com', '2024-08-24', 'child'),
('Jared', 'Ellis', 'jose76@diaz-miller.net', '2024-01-21', 'child'),
('Melissa', 'Whitney', 'beckermelissa@yahoo.com', '2024-09-01', 'child'),
('Jennifer', 'Snow', 'whitelisa@gmail.com', '2024-03-04', 'senior'),
('Tracey', 'Lee', 'kevin79@hotmail.com', '2024-08-21', 'adult'),
('Jessica', 'Villegas', 'hughesphyllis@bishop.com', '2024-03-12', 'child'),
('Paul', 'Graham', 'ronald76@jones.com', '2024-03-27', 'adult'),
('Tasha', 'Chapman', 'crose@hotmail.com', '2024-07-27', 'child'),
('Jeffrey', 'Chen', 'mark34@hotmail.com', '2024-08-04', 'adult'),
('William', 'Parrish', 'kennethtaylor@hotmail.com', '2023-12-16', 'adult'),
('Kendra', 'Nelson', 'katherinejohnson@gmail.com', '2024-02-07', 'adult'),
('Donna', 'Hebert', 'mphelps@davis.biz', '2024-07-15', 'child'),
('Christian', 'Frye', 'xreed@pruitt.com', '2024-02-17', 'adult'),
('Elaine', 'Turner', 'virginia54@gmail.com', '2023-12-04', 'child'),
('Ashley', 'Waller', 'brookslarry@yahoo.com', '2023-11-29', 'senior'),
('Mary', 'Nielsen', 'juan86@powell.info', '2024-03-27', 'senior'),
('Matthew', 'Mccullough', 'kevin82@smith.com', '2024-05-23', 'child'),
('Jean', 'Thomas', 'pclarke@jones.org', '2024-04-01', 'child'),
('Kimberly', 'Green', 'hancockandrea@harrison-mcdaniel.com', '2023-11-30', 'senior'),
('Devin', 'Pacheco', 'kaylaparker@hotmail.com', '2024-09-01', 'child'),
('Joshua', 'Hinton', 'mannjonathan@hotmail.com', '2024-05-19', 'child'),
('Hailey', 'Anderson', 'ozhang@gmail.com', '2024-01-02', 'adult');

INSERT INTO visitor_feedback (visitor_id, feedback_date, comments, rating) VALUES
(1, '2024-09-25', 'The animal exhibits were well-maintained and informative.', 4),
(2, '2024-09-04', 'I enjoyed the interactive displays, but some areas felt overcrowded.', 3),
(3, '2023-10-29', 'The reptile house was fascinating, but it could use more signage.', 3),
(4, '2024-07-07', 'The food options were limited and overpriced.', 1),
(5, '2024-05-30', 'I loved seeing the big cats up close; the staff was very knowledgeable!', 5),
(6, '2024-03-19', 'The zoo layout was confusing, and we had trouble finding some exhibits.', 3),
(7, '2024-09-24', 'Great experience, but it would be nice to have more shaded seating areas.', 2),
(8, '2024-07-21', 'The dolphin show was amazing! Highly recommend it.', 3),
(9, '2024-04-18', 'Overall a fun day, but some animals seemed to be in small enclosures.', 3),
(10, '2024-10-19', 'The staff was friendly, but I wish there were more educational programs.', 3),
(11, '2024-03-08', 'The butterfly garden was beautiful, a highlight of our visit!', 4),
(12, '2024-01-16', 'Very clean facilities, but the ticket lines were too long.', 4),
(13, '2024-10-07', 'The zoo was enjoyable, but some animal habitats looked outdated.', 2),
(14, '2024-07-07', 'Loved the petting zoo! My kids had a blast.', 2),
(15, '2023-12-10', 'We were disappointed that the elephants were not on display.', 1),
(16, '2024-07-17', 'The penguin exhibit was fun to watch; they were very active!', 1),
(17, '2024-04-16', 'Great variety of animals, but I wish there were more educational talks.', 3),
(18, '2023-11-10', 'Our family enjoyed the day, but it would help to have more maps available.', 1),
(19, '2024-06-28', 'I appreciated the conservation efforts showcased throughout the zoo.', 2),
(20, '2024-02-11', 'The zoo was wonderful; I would recommend visiting during the morning for fewer crowds.', 3);

COMMIT;