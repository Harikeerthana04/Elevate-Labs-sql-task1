-- SQL Script for Library Management System Schema

-- It's good practice to drop the database if it exists for a clean setup
DROP DATABASE IF EXISTS library_management_system;

-- Create the new database
CREATE DATABASE library_management_system;

-- Select the database to work on
USE library_management_system;

-- -----------------------------------------------------
-- Table: Authors
-- Stores information about book authors.
-- -----------------------------------------------------
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each author
    first_name VARCHAR(100) NOT NULL,         -- Author's first name
    last_name VARCHAR(100) NOT NULL,          -- Author's last name
    nationality VARCHAR(50),                  -- Author's nationality (optional)
    -- Constraint to ensure that first_name and last_name are not empty strings after trimming
    CONSTRAINT chk_author_names CHECK (LENGTH(TRIM(first_name)) > 0 AND LENGTH(TRIM(last_name)) > 0)
) ENGINE=InnoDB; -- Using InnoDB for transaction support and referential integrity

-- -----------------------------------------------------
-- Table: Genres
-- Stores different categories or types of books.
-- -----------------------------------------------------
CREATE TABLE Genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each genre
    genre_name VARCHAR(100) UNIQUE NOT NULL  -- Name of the genre, must be unique
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: Books
-- Stores details about each book available in the library.
-- -----------------------------------------------------
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,  -- Unique identifier for each book
    title VARCHAR(255) NOT NULL,             -- Title of the book
    isbn VARCHAR(13) UNIQUE NOT NULL,        -- International Standard Book Number, must be unique
    publication_year INT,                    -- Year the book was published
    -- Constraint to ensure publication_year is a reasonable value.
    -- Removed YEAR(CURDATE()) as it's not allowed in CHECK constraints in many MySQL versions.
    CONSTRAINT chk_publication_year CHECK (publication_year >= 1000)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: BookAuthors
-- Linking table to resolve the many-to-many relationship between Books and Authors.
-- A book can have multiple authors, and an author can write multiple books.
-- -----------------------------------------------------
CREATE TABLE BookAuthors (
    book_id INT NOT NULL,    -- Foreign Key referencing Books table
    author_id INT NOT NULL,  -- Foreign Key referencing Authors table
    PRIMARY KEY (book_id, author_id), -- Composite Primary Key to ensure unique book-author pairs
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE, -- If a book is deleted, its author links are removed
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE -- If an author is deleted, their book links are removed
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: BookGenres
-- Linking table to resolve the many-to-many relationship between Books and Genres.
-- A book can belong to multiple genres, and a genre can include multiple books.
-- -----------------------------------------------------
CREATE TABLE BookGenres (
    book_id INT NOT NULL,    -- Foreign Key referencing Books table
    genre_id INT NOT NULL,   -- Foreign Key referencing Genres table
    PRIMARY KEY (book_id, genre_id), -- Composite Primary Key to ensure unique book-genre pairs
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE, -- If a book is deleted, its genre links are removed
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) ON DELETE CASCADE -- If a genre is deleted, its book links are removed
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: Borrowers
-- Stores information about the library members who borrow books.
-- -----------------------------------------------------
CREATE TABLE Borrowers (
    borrower_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each borrower
    first_name VARCHAR(100) NOT NULL,           -- Borrower's first name
    last_name VARCHAR(100) NOT NULL,            -- Borrower's last name
    email VARCHAR(255) UNIQUE NOT NULL,         -- Borrower's email, must be unique
    phone_number VARCHAR(20),                   -- Borrower's phone number (optional)
    address TEXT,                               -- Borrower's address (optional)
    -- Basic check for email format
    CONSTRAINT chk_borrower_email CHECK (email LIKE '%_@__%.__%')
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: Loans
-- Records each instance of a book being borrowed by a borrower.
-- This handles "One borrower can borrow many books" and "One book can be borrowed by many borrowers over time".
-- -----------------------------------------------------
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique identifier for each loan record
    book_id INT NOT NULL,                 -- Foreign Key referencing the Books table (which book is borrowed)
    borrower_id INT NOT NULL,             -- Foreign Key referencing the Borrowers table (who borrowed the book)
    loan_date DATE NOT NULL,              -- Date the book was borrowed
    due_date DATE NOT NULL,               -- Date the book is due for return
    return_date DATE,                     -- Date the book was actually returned (NULL if not yet returned)
    -- Foreign Key constraints without CASCADE for loans, as deleting a book/borrower might not delete past loans
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (borrower_id) REFERENCES Borrowers(borrower_id),
    -- Constraints for logical date sequence
    CONSTRAINT chk_loan_dates CHECK (loan_date <= due_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Optional: Adding Indexes for performance on frequently searched columns
-- These indexes can speed up queries that filter or sort by these columns.
-- -----------------------------------------------------
CREATE INDEX idx_book_title ON Books(title);
CREATE INDEX idx_book_isbn ON Books(isbn);
CREATE INDEX idx_author_last_name ON Authors(last_name);
CREATE INDEX idx_borrower_email ON Borrowers(email);
CREATE INDEX idx_loan_dates ON Loans(loan_date, due_date);


-- -----------------------------------------------------
-- Sample Data Insertion
-- Insert some realistic data into the tables to test the schema.
-- -----------------------------------------------------

-- Authors
INSERT INTO Authors (first_name, last_name, nationality) VALUES
('Jane', 'Austen', 'British'),
('George', 'Orwell', 'British'),
('J.R.R.', 'Tolkien', 'British'),
('Agatha', 'Christie', 'British'),
('Stephen', 'King', 'American');

-- Genres
INSERT INTO Genres (genre_name) VALUES
('Fiction'),
('Fantasy'),
('Classic'),
('Mystery'),
('Horror'),
('Science Fiction');

-- Books
INSERT INTO Books (title, isbn, publication_year) VALUES
('Pride and Prejudice', '9780141439518', 1813),
('1984', '9780451524935', 1949),
('The Hobbit', '9780345339683', 1937),
('Murder on the Orient Express', '9780062073495', 1934),
('It', '9780451457813', 1986),
('The Lord of the Rings', '9780618053267', 1954);

-- BookAuthors (Linking Books to Authors)
INSERT INTO BookAuthors (book_id, author_id) VALUES
((SELECT book_id FROM Books WHERE title = 'Pride and Prejudice'), (SELECT author_id FROM Authors WHERE last_name = 'Austen')),
((SELECT book_id FROM Books WHERE title = '1984'), (SELECT author_id FROM Authors WHERE last_name = 'Orwell')),
((SELECT book_id FROM Books WHERE title = 'The Hobbit'), (SELECT author_id FROM Authors WHERE last_name = 'Tolkien')),
((SELECT book_id FROM Books WHERE title = 'Murder on the Orient Express'), (SELECT author_id FROM Authors WHERE last_name = 'Christie')),
((SELECT book_id FROM Books WHERE title = 'It'), (SELECT author_id FROM Authors WHERE last_name = 'King')),
((SELECT book_id FROM Books WHERE title = 'The Lord of the Rings'), (SELECT author_id FROM Authors WHERE last_name = 'Tolkien')); -- Multiple books by same author

-- BookGenres (Linking Books to Genres)
INSERT INTO BookGenres (book_id, genre_id) VALUES
((SELECT book_id FROM Books WHERE title = 'Pride and Prejudice'), (SELECT genre_id FROM Genres WHERE genre_name = 'Classic')),
((SELECT book_id FROM Books WHERE title = 'Pride and Prejudice'), (SELECT genre_id FROM Genres WHERE genre_name = 'Fiction')),
((SELECT book_id FROM Books WHERE title = '1984'), (SELECT genre_id FROM Genres WHERE genre_name = 'Science Fiction')),
((SELECT book_id FROM Books WHERE title = '1984'), (SELECT genre_id FROM Genres WHERE genre_name = 'Classic')),
((SELECT book_id FROM Books WHERE title = 'The Hobbit'), (SELECT genre_id FROM Genres WHERE genre_name = 'Fantasy')),
((SELECT book_id FROM Books WHERE title = 'The Hobbit'), (SELECT genre_id FROM Genres WHERE genre_name = 'Fiction')),
((SELECT book_id FROM Books WHERE title = 'Murder on the Orient Express'), (SELECT genre_id FROM Genres WHERE genre_name = 'Mystery')),
((SELECT book_id FROM Books WHERE title = 'It'), (SELECT genre_id FROM Genres WHERE genre_name = 'Horror')),
((SELECT book_id FROM Books WHERE title = 'The Lord of the Rings'), (SELECT genre_id FROM Genres WHERE genre_name = 'Fantasy'));


-- Borrowers
INSERT INTO Borrowers (first_name, last_name, email, phone_number, address) VALUES
('Alice', 'Smith', 'alice.smith@example.com', '123-456-7890', '123 Main St, Anytown'),
('Bob', 'Johnson', 'bob.johnson@example.com', '987-654-3210', '456 Oak Ave, Somewhereville'),
('Charlie', 'Brown', 'charlie.brown@example.com', '555-123-4567', '789 Pine Ln, Nowhere City');

-- Loans
-- Note: Replace CURDATE() with specific dates if testing past scenarios, or keep for current loans
INSERT INTO Loans (book_id, borrower_id, loan_date, due_date, return_date) VALUES
((SELECT book_id FROM Books WHERE title = 'Pride and Prejudice'), (SELECT borrower_id FROM Borrowers WHERE email = 'alice.smith@example.com'), '2025-06-01', '2025-06-15', '2025-06-14'), -- Returned
((SELECT book_id FROM Books WHERE title = '1984'), (SELECT borrower_id FROM Borrowers WHERE email = 'bob.johnson@example.com'), '2025-06-10', '2025-06-25', NULL), -- Currently out
((SELECT book_id FROM Books WHERE title = 'The Hobbit'), (SELECT borrower_id FROM Borrowers WHERE email = 'charlie.brown@example.com'), '2025-06-15', '2025-06-30', NULL), -- Currently out
((SELECT book_id FROM Books WHERE title = 'Pride and Prejudice'), (SELECT borrower_id FROM Borrowers WHERE email = 'bob.johnson@example.com'), '2025-06-20', '2025-07-05', NULL); -- Borrowed again by a different person
