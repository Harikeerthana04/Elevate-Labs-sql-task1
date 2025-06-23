Library Management System SQL Schema
This repository contains the SQL schema and an Entity-Relationship (ER) Diagram for a Library Management System, developed as part of an SQL Developer internship task.

Project Overview
The objective of this task was to design and implement a relational database schema for a library, focusing on database creation, table definition, and establishing relationships using primary and foreign keys.

Chosen Domain: Library Management System
The domain selected for this task is a Library Management System, which aims to manage books, authors, borrowers, and the borrowing process.

Entities and Relationships
The following core entities have been identified and modeled in the database:

Authors: Stores information about the authors of books.

author_id (Primary Key)

first_name, last_name, nationality

Genres: Stores different categories or types of books.

genre_id (Primary Key)

genre_name (Unique)

Books: Contains details about each book available in the library.

book_id (Primary Key)

title, isbn (Unique), publication_year

Borrowers: Stores information about the library members.

borrower_id (Primary Key)

first_name, last_name, email (Unique), phone_number, address

Loans: Records each instance of a book being borrowed by a borrower.

loan_id (Primary Key)

book_id (Foreign Key), borrower_id (Foreign Key), loan_date, due_date, return_date

Relationships Implemented:
Books and Authors (Many-to-Many): A book can have multiple authors, and an author can write multiple books. This is resolved using a linking table called BookAuthors.

BookAuthors contains book_id and author_id as a composite primary key and foreign keys.

Books and Genres (Many-to-Many): A book can belong to one or more genres, and a genre can include multiple books. This is resolved using a linking table called BookGenres.

BookGenres contains book_id and genre_id as a composite primary key and foreign keys.

Borrowers and Loans (One-to-Many): One borrower can borrow many books over time. The Loans table references the Borrowers table via borrower_id.

Books and Loans (One-to-Many): A single book title can be borrowed multiple times by different borrowers over time. The Loans table references the Books table via book_id.

Deliverables
This repository includes:

library_management_system_schema.sql: This SQL script contains all the Data Definition Language (DDL) statements to create the library_management_system database, define all tables, set up primary and foreign key constraints, and add relevant check constraints and indexes. It also includes sample Data Manipulation Language (DML) statements to populate the tables with initial data.

library_er_diagram.png (or .svg): An Entity-Relationship (ER) Diagram providing a visual representation of the database schema, illustrating the entities, their attributes, and the relationships between them using standard notation.

How to Use
To set up this database:

Install MySQL: Ensure you have MySQL Server installed and running on your system.

Execute the SQL Script: Open your MySQL client (e.g., MySQL Workbench, command-line client) and execute the library_management_system_schema.sql script. This will create the database and populate it with sample data.

Generate ER Diagram: Use MySQL Workbench's "Reverse Engineer" feature (Database > Reverse Engineer...) to generate the ER diagram from the created database.
