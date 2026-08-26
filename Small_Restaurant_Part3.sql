-- Quarterly Database Project Part 3
-- Small Restaurant Database
-- Student: Paulson v.

DROP DATABASE IF EXISTS small_restaurant;
CREATE DATABASE small_restaurant
DEFAULT CHARACTER SET utf8mb4;
USE small_restaurant;

-- Create tables

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    customer_status VARCHAR(20) NOT NULL DEFAULT 'Active'
);

CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    employment_status VARCHAR(20) NOT NULL DEFAULT 'Active'
);

CREATE TABLE Restaurant_Tables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number VARCHAR(10) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    section_name VARCHAR(30),
    table_status VARCHAR(20) NOT NULL DEFAULT 'Available',
    CONSTRAINT chk_table_capacity CHECK (capacity > 0)
);

CREATE TABLE Menu_Items (
    menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(8,2) NOT NULL,
    availability VARCHAR(20) NOT NULL DEFAULT 'Available',
    CONSTRAINT chk_menu_price CHECK (price >= 0)
);

CREATE TABLE Discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    discount_name VARCHAR(100) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(8,2) NOT NULL,
    discount_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_discount_value CHECK (discount_value >= 0)
);

CREATE TABLE Gift_Cards (
    gift_card_id INT AUTO_INCREMENT PRIMARY KEY,
    card_code VARCHAR(40) NOT NULL UNIQUE,
    original_value DECIMAL(9,2) NOT NULL,
    current_balance DECIMAL(9,2) NOT NULL,
    issue_date DATE NOT NULL,
    gift_card_status VARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_gift_card_values CHECK (
        original_value >= 0
        AND current_balance >= 0
        AND current_balance <= original_value
    )
);

CREATE TABLE Employee_Shifts (
    shift_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    shift_role VARCHAR(50) NOT NULL,
    shift_status VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT fk_shift_employee
        FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    CONSTRAINT chk_shift_time CHECK (end_time > start_time)
);

CREATE INDEX idx_shift_date
ON Employee_Shifts(shift_date);

CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_datetime DATETIME NOT NULL,
    party_size INT NOT NULL,
    reservation_status VARCHAR(30) NOT NULL DEFAULT 'Confirmed',
    special_request VARCHAR(255),
    CONSTRAINT fk_reservation_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_reservation_table
        FOREIGN KEY (table_id) REFERENCES Restaurant_Tables(table_id),
    CONSTRAINT chk_party_size CHECK (party_size > 0)
);

CREATE INDEX idx_reservation_datetime
ON Reservations(reservation_datetime);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT NOT NULL,
    table_id INT,
    order_datetime DATETIME NOT NULL,
    closed_datetime DATETIME,
    order_type VARCHAR(20) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    subtotal DECIMAL(9,2) NOT NULL DEFAULT 0.00,
    discount_total DECIMAL(9,2) NOT NULL DEFAULT 0.00,
    tax_rate DECIMAL(5,4) NOT NULL DEFAULT 0.1000,
    tax_amount DECIMAL(9,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(9,2) NOT NULL DEFAULT 0.00,
    receipt_number VARCHAR(30) UNIQUE,
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_order_employee
        FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    CONSTRAINT fk_order_table
        FOREIGN KEY (table_id) REFERENCES Restaurant_Tables(table_id),
    CONSTRAINT chk_order_amounts CHECK (
        subtotal >= 0
        AND discount_total >= 0
        AND tax_amount >= 0
        AND total_amount >= 0
    ),
    CONSTRAINT chk_tax_rate CHECK (tax_rate >= 0 AND tax_rate <= 1)
);

CREATE INDEX idx_order_datetime
ON Orders(order_datetime);

CREATE INDEX idx_order_status
ON Orders(order_status);

CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8,2) NOT NULL,
    item_status VARCHAR(30) NOT NULL DEFAULT 'Ordered',
    special_instructions VARCHAR(255),
    adjustment_reason VARCHAR(255),
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT fk_orderitem_menu
        FOREIGN KEY (menu_item_id) REFERENCES Menu_Items(menu_item_id),
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price >= 0)
);

CREATE TABLE Order_Discounts (
    order_discount_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    discount_id INT NOT NULL,
    discount_amount DECIMAL(9,2) NOT NULL,
    CONSTRAINT uq_order_discount UNIQUE (order_id, discount_id),
    CONSTRAINT fk_orderdiscount_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT fk_orderdiscount_discount
        FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id),
    CONSTRAINT chk_order_discount_amount CHECK (discount_amount >= 0)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    gift_card_id INT,
    payment_datetime DATETIME NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_amount DECIMAL(9,2) NOT NULL,
    tip_amount DECIMAL(9,2) NOT NULL DEFAULT 0.00,
    payment_status VARCHAR(30) NOT NULL,
    transaction_reference VARCHAR(60),
    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT fk_payment_giftcard
        FOREIGN KEY (gift_card_id) REFERENCES Gift_Cards(gift_card_id),
    CONSTRAINT chk_payment_amount CHECK (payment_amount >= 0),
    CONSTRAINT chk_tip_amount CHECK (tip_amount >= 0)
);

CREATE INDEX idx_payment_datetime
ON Payments(payment_datetime);

-- Insert sample data

INSERT INTO Customers
(customer_id, customer_name, phone, email, customer_status)
VALUES
(1, 'Liam Smith', '206-555-1001', 'liam.smith@example.com', 'Active'),
(2, 'Emma Johnson', '206-555-1002', 'emma.johnson@example.com', 'Active'),
(3, 'Noah Brown', '206-555-1003', 'noah.brown@example.com', 'Active'),
(4, 'Olivia Davis', '206-555-1004', 'olivia.davis@example.com', 'Active'),
(5, 'Ethan Wilson', '206-555-1005', 'ethan.wilson@example.com', 'Active'),
(6, 'Ava Miller', '206-555-1006', 'ava.miller@example.com', 'Active'),
(7, 'Mason Moore', '206-555-1007', 'mason.moore@example.com', 'Active'),
(8, 'Sophia Taylor', '206-555-1008', 'sophia.taylor@example.com', 'Active'),
(9, 'Lucas Anderson', '206-555-1009', 'lucas.anderson@example.com', 'Active'),
(10, 'Mia Thomas', '206-555-1010', 'mia.thomas@example.com', 'Active'),
(11, 'James Jackson', '206-555-1011', 'james.jackson@example.com', 'Active'),
(12, 'Amelia White', '206-555-1012', 'amelia.white@example.com', 'Active'),
(13, 'Benjamin Harris', '206-555-1013', 'benjamin.harris@example.com', 'Active'),
(14, 'Isabella Martin', '206-555-1014', 'isabella.martin@example.com', 'Active'),
(15, 'Henry Thompson', '206-555-1015', 'henry.thompson@example.com', 'Active'),
(16, 'Charlotte Garcia', '206-555-1016', 'charlotte.garcia@example.com', 'Active'),
(17, 'Alexander Martinez', '206-555-1017', 'alexander.martinez@example.com', 'Active'),
(18, 'Harper Robinson', '206-555-1018', 'harper.robinson@example.com', 'Active'),
(19, 'Daniel Clark', '206-555-1019', 'daniel.clark@example.com', 'Active'),
(20, 'Evelyn Rodriguez', '206-555-1020', 'evelyn.rodriguez@example.com', 'Active'),
(21, 'Michael Lewis', '206-555-1021', 'michael.lewis@example.com', 'Active'),
(22, 'Abigail Lee', '206-555-1022', 'abigail.lee@example.com', 'Active'),
(23, 'Sebastian Walker', '206-555-1023', 'sebastian.walker@example.com', 'Active'),
(24, 'Emily Hall', '206-555-1024', 'emily.hall@example.com', 'Active'),
(25, 'Jack Allen', '206-555-1025', 'jack.allen@example.com', 'Active'),
(26, 'Ella Young', '206-555-1026', 'ella.young@example.com', 'Active'),
(27, 'Owen King', '206-555-1027', 'owen.king@example.com', 'Active'),
(28, 'Elizabeth Wright', '206-555-1028', 'elizabeth.wright@example.com', 'Active'),
(29, 'Samuel Scott', '206-555-1029', 'samuel.scott@example.com', 'Active'),
(30, 'Camila Green', '206-555-1030', 'camila.green@example.com', 'Active'),
(31, 'Leo Baker', '206-555-1031', 'leo.baker@example.com', 'Active'),
(32, 'Luna Adams', '206-555-1032', 'luna.adams@example.com', 'Active'),
(33, 'Mateo Nelson', '206-555-1033', 'mateo.nelson@example.com', 'Active'),
(34, 'Sofia Hill', '206-555-1034', 'sofia.hill@example.com', 'Active'),
(35, 'David Ramirez', '206-555-1035', 'david.ramirez@example.com', 'Active'),
(36, 'Avery Campbell', '206-555-1036', 'avery.campbell@example.com', 'Active'),
(37, 'Joseph Mitchell', '206-555-1037', 'joseph.mitchell@example.com', 'Inactive'),
(38, 'Mila Roberts', '206-555-1038', 'mila.roberts@example.com', 'Inactive'),
(39, 'John Carter', '206-555-1039', 'john.carter@example.com', 'Inactive'),
(40, 'Aria Phillips', '206-555-1040', 'aria.phillips@example.com', 'Inactive');

INSERT INTO Employees
(employee_id, employee_name, job_title, phone, email, employment_status)
VALUES
(1, 'Lucas Harris', 'Manager', '206-555-2001', 'lucas.harris@restaurant.example', 'Active'),
(2, 'Mia Martin', 'Server', '206-555-2002', 'mia.martin@restaurant.example', 'Active'),
(3, 'James Thompson', 'Server', '206-555-2003', 'james.thompson@restaurant.example', 'Active'),
(4, 'Amelia Garcia', 'Cook', '206-555-2004', 'amelia.garcia@restaurant.example', 'Active'),
(5, 'Benjamin Martinez', 'Cook', '206-555-2005', 'benjamin.martinez@restaurant.example', 'Active'),
(6, 'Isabella Robinson', 'Cashier', '206-555-2006', 'isabella.robinson@restaurant.example', 'Active'),
(7, 'Henry Clark', 'Host', '206-555-2007', 'henry.clark@restaurant.example', 'Active'),
(8, 'Charlotte Rodriguez', 'Manager', '206-555-2008', 'charlotte.rodriguez@restaurant.example', 'Active'),
(9, 'Alexander Lewis', 'Server', '206-555-2009', 'alexander.lewis@restaurant.example', 'Active'),
(10, 'Harper Lee', 'Server', '206-555-2010', 'harper.lee@restaurant.example', 'Active'),
(11, 'Daniel Walker', 'Cook', '206-555-2011', 'daniel.walker@restaurant.example', 'Active'),
(12, 'Evelyn Hall', 'Cook', '206-555-2012', 'evelyn.hall@restaurant.example', 'Inactive'),
(13, 'Michael Allen', 'Cashier', '206-555-2013', 'michael.allen@restaurant.example', 'Inactive');

INSERT INTO Restaurant_Tables
(table_id, table_number, capacity, section_name, table_status)
VALUES
(1, 'T01', 2, 'Window', 'Available'),
(2, 'T02', 2, 'Main', 'Available'),
(3, 'T03', 4, 'Patio', 'Available'),
(4, 'T04', 4, 'Private', 'Available'),
(5, 'T05', 4, 'Window', 'Available'),
(6, 'T06', 6, 'Main', 'Available'),
(7, 'T07', 6, 'Patio', 'Available'),
(8, 'T08', 8, 'Private', 'Available'),
(9, 'T09', 2, 'Window', 'Available'),
(10, 'T10', 4, 'Main', 'Available'),
(11, 'T11', 6, 'Patio', 'Available'),
(12, 'T12', 8, 'Private', 'Available');

INSERT INTO Menu_Items
(menu_item_id, item_name, category, price, availability)
VALUES
(1, 'Spring Rolls', 'Appetizer', 7.50, 'Available'),
(2, 'Chicken Wings', 'Appetizer', 11.95, 'Available'),
(3, 'Garlic Bread', 'Appetizer', 6.50, 'Available'),
(4, 'Calamari', 'Appetizer', 13.95, 'Available'),
(5, 'Edamame', 'Appetizer', 6.95, 'Available'),
(6, 'Tomato Soup', 'Soup', 7.50, 'Available'),
(7, 'Miso Soup', 'Soup', 5.50, 'Available'),
(8, 'Chicken Soup', 'Soup', 8.50, 'Unavailable'),
(9, 'Seafood Soup', 'Soup', 11.95, 'Available'),
(10, 'Vegetable Soup', 'Soup', 7.95, 'Available'),
(11, 'Caesar Salad', 'Salad', 10.95, 'Available'),
(12, 'Garden Salad', 'Salad', 9.50, 'Available'),
(13, 'Thai Beef Salad', 'Salad', 14.95, 'Available'),
(14, 'Chicken Salad', 'Salad', 12.95, 'Available'),
(15, 'Tofu Salad', 'Salad', 11.50, 'Available'),
(16, 'Grilled Salmon', 'Entree', 22.95, 'Available'),
(17, 'BBQ Chicken', 'Entree', 17.95, 'Available'),
(18, 'Beef Burger', 'Entree', 14.50, 'Available'),
(19, 'Pad Thai', 'Entree', 15.95, 'Unavailable'),
(20, 'Green Curry', 'Entree', 16.50, 'Available'),
(21, 'Spaghetti', 'Noodles', 15.50, 'Available'),
(22, 'Chicken Alfredo', 'Noodles', 17.50, 'Available'),
(23, 'Beef Noodles', 'Noodles', 16.95, 'Available'),
(24, 'Ramen', 'Noodles', 14.95, 'Available'),
(25, 'Drunken Noodles', 'Noodles', 16.95, 'Available'),
(26, 'Fried Rice', 'Rice', 13.95, 'Available'),
(27, 'Basil Rice', 'Rice', 14.95, 'Available'),
(28, 'Chicken Rice', 'Rice', 15.50, 'Available'),
(29, 'Shrimp Rice', 'Rice', 17.95, 'Available'),
(30, 'Vegetable Rice', 'Rice', 13.50, 'Available'),
(31, 'Cheesecake', 'Dessert', 7.95, 'Available'),
(32, 'Chocolate Cake', 'Dessert', 7.50, 'Available');

INSERT INTO Discounts
(discount_id, discount_name, discount_type, discount_value, discount_status)
VALUES
(1, 'Senior Discount', 'Percentage', 10.00, 'Active'),
(2, 'Student Discount', 'Percentage', 10.00, 'Active'),
(3, 'Employee Meal', 'Percentage', 50.00, 'Active'),
(4, 'Birthday Reward', 'Fixed', 10.00, 'Active'),
(5, 'Lunch Special', 'Fixed', 5.00, 'Active'),
(6, 'Loyalty Reward', 'Percentage', 15.00, 'Active');

INSERT INTO Gift_Cards
(gift_card_id, card_code, original_value, current_balance, issue_date, gift_card_status)
VALUES
(1, 'GIFT-2026-0001', 50.00, 37.17, '2026-07-05', 'Active'),
(2, 'GIFT-2026-0002', 75.00, 55.00, '2026-07-06', 'Active'),
(3, 'GIFT-2026-0003', 100.00, 90.14, '2026-07-07', 'Active'),
(4, 'GIFT-2026-0004', 50.00, 38.34, '2026-07-08', 'Active'),
(5, 'GIFT-2026-0005', 75.00, 64.68, '2026-07-09', 'Active'),
(6, 'GIFT-2026-0006', 100.00, 92.18, '2026-07-10', 'Active'),
(7, 'GIFT-2026-0007', 50.00, 39.92, '2026-07-11', 'Active'),
(8, 'GIFT-2026-0008', 75.00, 75.00, '2026-07-12', 'Active'),
(9, 'GIFT-2026-0009', 100.00, 100.00, '2026-07-13', 'Active'),
(10, 'GIFT-2026-0010', 50.00, 50.00, '2026-07-14', 'Active'),
(11, 'GIFT-2026-0011', 75.00, 75.00, '2026-07-15', 'Active'),
(12, 'GIFT-2026-0012', 100.00, 100.00, '2026-07-16', 'Active');

INSERT INTO Employee_Shifts
(shift_id, employee_id, shift_date, start_time, end_time, shift_role, shift_status)
VALUES
(1, 1, '2026-08-18', '10:00:00', '16:00:00', 'Manager', 'Completed'),
(2, 2, '2026-08-18', '16:00:00', '22:00:00', 'Server', 'Completed'),
(3, 3, '2026-08-18', '10:00:00', '16:00:00', 'Server', 'Completed'),
(4, 4, '2026-08-18', '16:00:00', '22:00:00', 'Cook', 'Completed'),
(5, 5, '2026-08-19', '10:00:00', '16:00:00', 'Cook', 'Completed'),
(6, 6, '2026-08-19', '16:00:00', '22:00:00', 'Cashier', 'Completed'),
(7, 7, '2026-08-19', '10:00:00', '16:00:00', 'Host', 'Completed'),
(8, 8, '2026-08-19', '16:00:00', '22:00:00', 'Manager', 'Completed'),
(9, 9, '2026-08-20', '10:00:00', '16:00:00', 'Server', 'Completed'),
(10, 10, '2026-08-20', '16:00:00', '22:00:00', 'Server', 'Completed'),
(11, 11, '2026-08-20', '10:00:00', '16:00:00', 'Cook', 'Completed'),
(12, 1, '2026-08-20', '16:00:00', '22:00:00', 'Manager', 'Completed'),
(13, 2, '2026-08-21', '10:00:00', '16:00:00', 'Server', 'Completed'),
(14, 3, '2026-08-21', '16:00:00', '22:00:00', 'Server', 'Completed'),
(15, 4, '2026-08-21', '10:00:00', '16:00:00', 'Cook', 'Completed'),
(16, 5, '2026-08-21', '16:00:00', '22:00:00', 'Cook', 'Completed'),
(17, 6, '2026-08-22', '10:00:00', '16:00:00', 'Cashier', 'Completed'),
(18, 7, '2026-08-22', '16:00:00', '22:00:00', 'Host', 'Completed'),
(19, 8, '2026-08-22', '10:00:00', '16:00:00', 'Manager', 'Completed'),
(20, 9, '2026-08-22', '16:00:00', '22:00:00', 'Server', 'Completed'),
(21, 10, '2026-08-23', '10:00:00', '16:00:00', 'Server', 'Completed'),
(22, 11, '2026-08-23', '16:00:00', '22:00:00', 'Cook', 'Completed'),
(23, 1, '2026-08-23', '10:00:00', '16:00:00', 'Manager', 'Completed'),
(24, 2, '2026-08-23', '16:00:00', '22:00:00', 'Server', 'Completed'),
(25, 3, '2026-08-24', '10:00:00', '16:00:00', 'Server', 'Completed'),
(26, 4, '2026-08-24', '16:00:00', '22:00:00', 'Cook', 'Completed'),
(27, 5, '2026-08-24', '10:00:00', '16:00:00', 'Cook', 'Completed'),
(28, 6, '2026-08-24', '16:00:00', '22:00:00', 'Cashier', 'Completed'),
(29, 7, '2026-08-25', '10:00:00', '16:00:00', 'Host', 'Scheduled'),
(30, 8, '2026-08-25', '16:00:00', '22:00:00', 'Manager', 'Scheduled'),
(31, 9, '2026-08-25', '10:00:00', '16:00:00', 'Server', 'Scheduled'),
(32, 10, '2026-08-25', '16:00:00', '22:00:00', 'Server', 'Scheduled'),
(33, 11, '2026-08-26', '10:00:00', '16:00:00', 'Cook', 'Scheduled'),
(34, 1, '2026-08-26', '16:00:00', '22:00:00', 'Manager', 'Scheduled'),
(35, 2, '2026-08-26', '10:00:00', '16:00:00', 'Server', 'Scheduled'),
(36, 3, '2026-08-26', '16:00:00', '22:00:00', 'Server', 'Scheduled'),
(37, 4, '2026-08-27', '10:00:00', '16:00:00', 'Cook', 'Scheduled'),
(38, 5, '2026-08-27', '16:00:00', '22:00:00', 'Cook', 'Scheduled'),
(39, 6, '2026-08-27', '10:00:00', '16:00:00', 'Cashier', 'Scheduled'),
(40, 7, '2026-08-27', '16:00:00', '22:00:00', 'Host', 'Scheduled');

INSERT INTO Reservations
(reservation_id, customer_id, table_id, reservation_datetime, party_size, reservation_status, special_request)
VALUES
(1, 3, 5, '2026-08-20 17:00:00', 3, 'Completed', NULL),
(2, 6, 10, '2026-08-20 18:00:00', 4, 'Completed', NULL),
(3, 9, 3, '2026-08-20 19:00:00', 2, 'Completed', 'Birthday celebration'),
(4, 12, 8, '2026-08-20 20:00:00', 6, 'Completed', NULL),
(5, 15, 1, '2026-08-21 17:00:00', 2, 'Completed', 'Window seat'),
(6, 18, 6, '2026-08-21 18:00:00', 3, 'Completed', NULL),
(7, 21, 11, '2026-08-21 19:00:00', 4, 'Completed', 'Wheelchair access'),
(8, 24, 4, '2026-08-21 20:00:00', 4, 'Completed', NULL),
(9, 27, 9, '2026-08-22 17:00:00', 2, 'Cancelled', NULL),
(10, 30, 2, '2026-08-22 18:00:00', 2, 'Completed', NULL),
(11, 33, 7, '2026-08-22 19:00:00', 3, 'No-show', 'Birthday celebration'),
(12, 36, 12, '2026-08-22 20:00:00', 7, 'Completed', NULL),
(13, 39, 5, '2026-08-23 17:00:00', 3, 'Completed', 'Window seat'),
(14, 2, 10, '2026-08-23 18:00:00', 4, 'Completed', NULL),
(15, 5, 3, '2026-08-23 19:00:00', 2, 'Completed', 'Wheelchair access'),
(16, 8, 8, '2026-08-23 20:00:00', 4, 'Completed', NULL),
(17, 11, 1, '2026-08-24 17:00:00', 2, 'Completed', NULL),
(18, 14, 6, '2026-08-24 18:00:00', 5, 'Cancelled', NULL),
(19, 17, 11, '2026-08-24 19:00:00', 6, 'Completed', 'Birthday celebration'),
(20, 20, 4, '2026-08-24 20:00:00', 4, 'Completed', NULL),
(21, 23, 9, '2026-08-25 17:00:00', 2, 'Confirmed', 'Window seat'),
(22, 26, 2, '2026-08-25 18:00:00', 2, 'No-show', NULL),
(23, 29, 7, '2026-08-25 19:00:00', 5, 'Confirmed', 'Wheelchair access'),
(24, 32, 12, '2026-08-25 20:00:00', 5, 'Confirmed', NULL);

INSERT INTO Orders
(order_id, customer_id, employee_id, table_id, order_datetime, closed_datetime,
 order_type, order_status, subtotal, discount_total, tax_rate, tax_amount,
 total_amount, receipt_number)
VALUES
(1, 7, 3, 5, '2026-08-20 11:00:00', '2026-08-20 11:45:00', 'Dine-in', 'Completed', 36.40, 0.00, 0.1000, 3.64, 40.04, 'R-202608-0001'),
(2, 14, 6, NULL, '2026-08-20 12:15:00', '2026-08-20 13:00:00', 'Takeout', 'Completed', 56.45, 0.00, 0.1000, 5.65, 62.10, 'R-202608-0002'),
(3, 21, 9, NULL, '2026-08-20 13:30:00', '2026-08-20 14:15:00', 'Delivery', 'Completed', 52.90, 0.00, 0.1000, 5.29, 58.19, 'R-202608-0003'),
(4, 28, 1, 8, '2026-08-20 14:45:00', '2026-08-20 15:30:00', 'Dine-in', 'Completed', 47.90, 0.00, 0.1000, 4.79, 52.69, 'R-202608-0004'),
(5, 35, 4, NULL, '2026-08-20 17:00:00', '2026-08-20 17:45:00', 'Takeout', 'Completed', 32.40, 3.24, 0.1000, 2.92, 32.08, 'R-202608-0005'),
(6, NULL, 7, NULL, '2026-08-20 18:15:00', '2026-08-20 19:00:00', 'Delivery', 'Completed', 49.45, 0.00, 0.1000, 4.95, 54.40, 'R-202608-0006'),
(7, 9, 10, 11, '2026-08-20 19:30:00', '2026-08-20 20:15:00', 'Dine-in', 'Completed', 41.45, 0.00, 0.1000, 4.15, 45.60, 'R-202608-0007'),
(8, 16, 2, NULL, '2026-08-20 20:45:00', '2026-08-20 21:30:00', 'Takeout', 'Completed', 49.35, 0.00, 0.1000, 4.94, 54.29, 'R-202608-0008'),
(9, 23, 5, NULL, '2026-08-21 11:00:00', '2026-08-21 11:45:00', 'Delivery', 'Completed', 40.40, 0.00, 0.1000, 4.04, 44.44, 'R-202608-0009'),
(10, 30, 8, 2, '2026-08-21 12:15:00', '2026-08-21 13:00:00', 'Dine-in', 'Completed', 58.45, 5.85, 0.1000, 5.26, 57.86, 'R-202608-0010'),
(11, 37, 11, NULL, '2026-08-21 13:30:00', '2026-08-21 14:15:00', 'Takeout', 'Completed', 43.45, 0.00, 0.1000, 4.35, 47.80, 'R-202608-0011'),
(12, NULL, 3, NULL, '2026-08-21 14:45:00', '2026-08-21 15:30:00', 'Delivery', 'Completed', 53.35, 0.00, 0.1000, 5.34, 58.69, 'R-202608-0012'),
(13, 11, 6, 5, '2026-08-21 17:00:00', '2026-08-21 17:45:00', 'Dine-in', 'Completed', 37.95, 0.00, 0.1000, 3.80, 41.75, 'R-202608-0013'),
(14, 18, 9, NULL, '2026-08-21 18:15:00', '2026-08-21 19:00:00', 'Takeout', 'Completed', 23.45, 0.00, 0.1000, 2.35, 25.80, 'R-202608-0014'),
(15, 25, 1, NULL, '2026-08-21 19:30:00', '2026-08-21 20:15:00', 'Delivery', 'Completed', 44.85, 22.43, 0.1000, 2.24, 24.66, 'R-202608-0015'),
(16, 32, 4, 8, '2026-08-21 20:45:00', '2026-08-21 21:30:00', 'Dine-in', 'Completed', 60.85, 0.00, 0.1000, 6.09, 66.94, 'R-202608-0016'),
(17, 39, 7, NULL, '2026-08-22 11:00:00', '2026-08-22 11:45:00', 'Takeout', 'Completed', 29.45, 0.00, 0.1000, 2.95, 32.40, 'R-202608-0017'),
(18, NULL, 10, NULL, '2026-08-22 12:15:00', '2026-08-22 13:00:00', 'Delivery', 'Completed', 25.00, 0.00, 0.1000, 2.50, 27.50, 'R-202608-0018'),
(19, 13, 2, 11, '2026-08-22 13:30:00', '2026-08-22 14:15:00', 'Dine-in', 'Completed', 44.85, 0.00, 0.1000, 4.49, 49.34, 'R-202608-0019'),
(20, 20, 5, NULL, '2026-08-22 14:45:00', '2026-08-22 15:30:00', 'Takeout', 'Completed', 36.50, 10.00, 0.1000, 2.65, 29.15, 'R-202608-0020'),
(21, 27, 8, NULL, '2026-08-22 17:00:00', '2026-08-22 17:45:00', 'Delivery', 'Completed', 15.90, 0.00, 0.1000, 1.59, 17.49, 'R-202608-0021'),
(22, 34, 11, 2, '2026-08-22 18:15:00', '2026-08-22 19:00:00', 'Dine-in', 'Completed', 26.90, 0.00, 0.1000, 2.69, 29.59, 'R-202608-0022'),
(23, 1, 3, NULL, '2026-08-22 19:30:00', '2026-08-22 20:15:00', 'Takeout', 'Completed', 52.85, 0.00, 0.1000, 5.29, 58.14, 'R-202608-0023'),
(24, NULL, 6, NULL, '2026-08-22 20:45:00', '2026-08-22 21:30:00', 'Delivery', 'Completed', 32.95, 0.00, 0.1000, 3.30, 36.25, 'R-202608-0024'),
(25, 15, 9, 5, '2026-08-23 11:00:00', '2026-08-23 11:45:00', 'Dine-in', 'Completed', 28.45, 5.00, 0.1000, 2.35, 25.80, 'R-202608-0025'),
(26, 22, 1, NULL, '2026-08-23 12:15:00', '2026-08-23 13:00:00', 'Takeout', 'Completed', 29.90, 0.00, 0.1000, 2.99, 32.89, 'R-202608-0026'),
(27, 29, 4, NULL, '2026-08-23 13:30:00', '2026-08-23 14:15:00', 'Delivery', 'Completed', 48.95, 0.00, 0.1000, 4.90, 53.85, 'R-202608-0027'),
(28, 36, 7, 8, '2026-08-23 14:45:00', '2026-08-23 15:30:00', 'Dine-in', 'Completed', 40.95, 0.00, 0.1000, 4.10, 45.05, 'R-202608-0028'),
(29, 3, 10, NULL, '2026-08-23 17:00:00', '2026-08-23 17:45:00', 'Takeout', 'Completed', 28.90, 0.00, 0.1000, 2.89, 31.79, 'R-202608-0029'),
(30, NULL, 2, NULL, '2026-08-23 18:15:00', '2026-08-23 19:00:00', 'Delivery', 'Completed', 20.90, 3.14, 0.1000, 1.78, 19.54, 'R-202608-0030'),
(31, 17, 5, 11, '2026-08-23 19:30:00', '2026-08-23 20:15:00', 'Dine-in', 'Completed', 34.95, 0.00, 0.1000, 3.50, 38.45, 'R-202608-0031'),
(32, 24, 8, NULL, '2026-08-23 20:45:00', '2026-08-23 21:30:00', 'Takeout', 'Completed', 25.95, 0.00, 0.1000, 2.60, 28.55, 'R-202608-0032'),
(33, 31, 11, NULL, '2026-08-24 11:00:00', '2026-08-24 11:45:00', 'Delivery', 'Completed', 19.45, 0.00, 0.1000, 1.95, 21.40, 'R-202608-0033'),
(34, 38, 3, 2, '2026-08-24 12:15:00', '2026-08-24 13:00:00', 'Dine-in', 'Completed', 25.45, 2.55, 0.1000, 2.29, 25.19, 'R-202608-0034'),
(35, 5, 6, NULL, '2026-08-24 13:30:00', NULL, 'Takeout', 'Preparing', 44.95, 0.00, 0.1000, 4.50, 49.45, NULL),
(36, NULL, 9, NULL, '2026-08-24 14:45:00', NULL, 'Delivery', 'Preparing', 35.95, 0.00, 0.1000, 3.60, 39.55, NULL),
(37, 19, 1, 5, '2026-08-24 17:00:00', NULL, 'Dine-in', 'Ready', 25.45, 0.00, 0.1000, 2.55, 28.00, NULL),
(38, 26, 4, NULL, '2026-08-24 18:15:00', NULL, 'Takeout', 'Ready', 32.45, 0.00, 0.1000, 3.25, 35.70, NULL),
(39, 33, 7, NULL, '2026-08-24 19:30:00', '2026-08-24 19:45:00', 'Delivery', 'Cancelled', 30.50, 0.00, 0.1000, 3.05, 33.55, NULL),
(40, 40, 10, 8, '2026-08-24 20:45:00', '2026-08-24 21:00:00', 'Dine-in', 'Cancelled', 36.40, 0.00, 0.1000, 3.64, 40.04, NULL);

INSERT INTO Order_Items
(order_item_id, order_id, menu_item_id, quantity, unit_price,
 item_status, special_instructions, adjustment_reason)
VALUES
(1, 1, 3, 1, 6.50, 'Served', NULL, NULL),
(2, 1, 14, 1, 12.95, 'Served', NULL, NULL),
(3, 1, 25, 1, 16.95, 'Served', NULL, NULL),
(4, 2, 6, 1, 7.50, 'Served', NULL, NULL),
(5, 2, 17, 1, 17.95, 'Served', NULL, NULL),
(6, 2, 28, 2, 15.50, 'Served', NULL, NULL),
(7, 3, 9, 1, 11.95, 'Served', NULL, NULL),
(8, 3, 20, 2, 16.50, 'Served', NULL, NULL),
(9, 3, 31, 1, 7.95, 'Served', NULL, NULL),
(10, 4, 12, 2, 9.50, 'Served', NULL, NULL),
(11, 4, 23, 1, 16.95, 'Served', 'Extra spicy', NULL),
(12, 4, 2, 1, 11.95, 'Served', NULL, NULL),
(13, 5, 15, 1, 11.50, 'Served', 'No onions', NULL),
(14, 5, 26, 1, 13.95, 'Served', NULL, NULL),
(15, 5, 5, 1, 6.95, 'Served', NULL, NULL),
(16, 6, 18, 1, 14.50, 'Served', NULL, NULL),
(17, 6, 29, 1, 17.95, 'Served', 'Sauce on the side', NULL),
(18, 6, 8, 2, 8.50, 'Served', NULL, NULL),
(19, 7, 21, 1, 15.50, 'Served', NULL, NULL),
(20, 7, 32, 2, 7.50, 'Served', NULL, NULL),
(21, 7, 11, 1, 10.95, 'Served', NULL, NULL),
(22, 8, 24, 2, 14.95, 'Served', 'Extra spicy', NULL),
(23, 8, 3, 1, 6.50, 'Served', NULL, NULL),
(24, 8, 14, 1, 12.95, 'Served', NULL, NULL),
(25, 9, 27, 1, 14.95, 'Served', NULL, NULL),
(26, 9, 6, 1, 7.50, 'Served', 'No onions', NULL),
(27, 9, 17, 1, 17.95, 'Served', NULL, NULL),
(28, 10, 30, 1, 13.50, 'Served', NULL, NULL),
(29, 10, 9, 1, 11.95, 'Served', NULL, NULL),
(30, 10, 20, 2, 16.50, 'Served', NULL, NULL),
(31, 11, 1, 1, 7.50, 'Served', NULL, NULL),
(32, 11, 12, 2, 9.50, 'Served', NULL, NULL),
(33, 11, 23, 1, 16.95, 'Served', 'Extra spicy', NULL),
(34, 12, 4, 2, 13.95, 'Served', 'Sauce on the side', NULL),
(35, 12, 15, 1, 11.50, 'Served', NULL, NULL),
(36, 12, 26, 1, 13.95, 'Served', NULL, NULL),
(37, 13, 7, 1, 5.50, 'Served', NULL, NULL),
(38, 13, 18, 1, 14.50, 'Served', NULL, NULL),
(39, 13, 29, 1, 17.95, 'Served', 'No onions', NULL),
(40, 14, 10, 1, 7.95, 'Served', NULL, NULL),
(41, 14, 21, 1, 15.50, 'Served', NULL, NULL),
(42, 15, 13, 1, 14.95, 'Served', NULL, NULL),
(43, 15, 24, 2, 14.95, 'Served', NULL, NULL),
(44, 16, 16, 2, 22.95, 'Served', 'Extra spicy', NULL),
(45, 16, 27, 1, 14.95, 'Served', NULL, NULL),
(46, 17, 19, 1, 15.95, 'Served', NULL, NULL),
(47, 17, 30, 1, 13.50, 'Served', NULL, NULL),
(48, 18, 22, 1, 17.50, 'Served', NULL, NULL),
(49, 18, 1, 1, 7.50, 'Served', NULL, NULL),
(50, 19, 25, 1, 16.95, 'Served', NULL, NULL),
(51, 19, 4, 2, 13.95, 'Served', 'Sauce on the side', NULL),
(52, 20, 28, 2, 15.50, 'Served', 'No onions', NULL),
(53, 20, 7, 1, 5.50, 'Served', NULL, NULL),
(54, 21, 31, 1, 7.95, 'Served', NULL, NULL),
(55, 21, 10, 1, 7.95, 'Served', 'Extra spicy', NULL),
(56, 22, 2, 1, 11.95, 'Served', NULL, NULL),
(57, 22, 13, 1, 14.95, 'Served', NULL, NULL),
(58, 23, 5, 1, 6.95, 'Served', NULL, NULL),
(59, 23, 16, 2, 22.95, 'Served', NULL, NULL),
(60, 24, 8, 2, 8.50, 'Served', NULL, NULL),
(61, 24, 19, 1, 15.95, 'Served', NULL, NULL),
(62, 25, 11, 1, 10.95, 'Served', NULL, NULL),
(63, 25, 22, 1, 17.50, 'Served', NULL, NULL),
(64, 26, 14, 1, 12.95, 'Served', NULL, NULL),
(65, 26, 25, 1, 16.95, 'Served', 'No onions', NULL),
(66, 27, 17, 1, 17.95, 'Served', 'Extra spicy', NULL),
(67, 27, 28, 2, 15.50, 'Served', NULL, NULL),
(68, 28, 20, 2, 16.50, 'Served', 'Sauce on the side', NULL),
(69, 28, 31, 1, 7.95, 'Served', NULL, NULL),
(70, 29, 23, 1, 16.95, 'Served', NULL, NULL),
(71, 29, 2, 1, 11.95, 'Served', NULL, NULL),
(72, 30, 26, 1, 13.95, 'Served', NULL, NULL),
(73, 30, 5, 1, 6.95, 'Served', NULL, NULL),
(74, 31, 29, 1, 17.95, 'Served', NULL, NULL),
(75, 31, 8, 2, 8.50, 'Served', NULL, NULL),
(76, 32, 32, 2, 7.50, 'Served', NULL, NULL),
(77, 32, 11, 1, 10.95, 'Served', 'Extra spicy', NULL),
(78, 33, 3, 1, 6.50, 'Served', 'No onions', NULL),
(79, 33, 14, 1, 12.95, 'Served', NULL, NULL),
(80, 34, 6, 1, 7.50, 'Served', NULL, NULL),
(81, 34, 17, 1, 17.95, 'Served', NULL, NULL),
(82, 35, 9, 1, 11.95, 'Preparing', NULL, NULL),
(83, 35, 20, 2, 16.50, 'Preparing', NULL, NULL),
(84, 36, 12, 2, 9.50, 'Preparing', NULL, NULL),
(85, 36, 23, 1, 16.95, 'Preparing', 'Sauce on the side', NULL),
(86, 37, 15, 1, 11.50, 'Ready', NULL, NULL),
(87, 37, 26, 1, 13.95, 'Ready', NULL, NULL),
(88, 38, 18, 1, 14.50, 'Ready', 'Extra spicy', NULL),
(89, 38, 29, 1, 17.95, 'Ready', NULL, NULL),
(90, 39, 21, 1, 15.50, 'Cancelled', NULL, 'Customer cancelled order'),
(91, 39, 32, 2, 7.50, 'Cancelled', 'No onions', 'Customer cancelled order'),
(92, 40, 24, 2, 14.95, 'Cancelled', NULL, 'Customer cancelled order'),
(93, 40, 3, 1, 6.50, 'Cancelled', NULL, 'Customer cancelled order');

INSERT INTO Order_Discounts
(order_discount_id, order_id, discount_id, discount_amount)
VALUES
(1, 5, 1, 3.24),
(2, 10, 2, 5.85),
(3, 15, 3, 22.43),
(4, 20, 4, 10.00),
(5, 25, 5, 5.00),
(6, 30, 6, 3.14),
(7, 34, 1, 2.55);

INSERT INTO Payments
(payment_id, order_id, gift_card_id, payment_datetime, payment_method,
 payment_amount, tip_amount, payment_status, transaction_reference)
VALUES
(1, 1, NULL, '2026-08-20 11:47:00', 'Cash', 40.04, 6.01, 'Paid', NULL),
(2, 2, NULL, '2026-08-20 13:02:00', 'Credit Card', 62.10, 0.00, 'Paid', 'TXN-000002'),
(3, 3, NULL, '2026-08-20 14:17:00', 'Debit Card', 58.19, 0.00, 'Paid', 'TXN-000003'),
(4, 4, NULL, '2026-08-20 15:32:00', 'Mobile Pay', 52.69, 7.90, 'Paid', 'TXN-000004'),
(5, 5, 1, '2026-08-20 17:47:00', 'Gift Card', 12.83, 0.00, 'Paid', 'GC-0001'),
(6, 5, NULL, '2026-08-20 17:48:00', 'Credit Card', 19.25, 3.85, 'Paid', 'TXN-000006'),
(7, 6, NULL, '2026-08-20 19:02:00', 'Credit Card', 54.40, 0.00, 'Paid', 'TXN-000007'),
(8, 7, NULL, '2026-08-20 20:17:00', 'Debit Card', 45.60, 6.84, 'Paid', 'TXN-000008'),
(9, 8, NULL, '2026-08-20 21:32:00', 'Mobile Pay', 54.29, 0.00, 'Paid', 'TXN-000009'),
(10, 9, NULL, '2026-08-21 11:47:00', 'Cash', 44.44, 0.00, 'Paid', NULL),
(11, 10, 2, '2026-08-21 13:02:00', 'Gift Card', 20.00, 0.00, 'Paid', 'GC-0002'),
(12, 10, NULL, '2026-08-21 13:03:00', 'Credit Card', 37.86, 6.94, 'Paid', 'TXN-000012'),
(13, 11, NULL, '2026-08-21 14:17:00', 'Debit Card', 47.80, 0.00, 'Paid', 'TXN-000013'),
(14, 12, NULL, '2026-08-21 15:32:00', 'Mobile Pay', 58.69, 0.00, 'Paid', 'TXN-000014'),
(15, 13, NULL, '2026-08-21 17:47:00', 'Cash', 41.75, 6.26, 'Paid', NULL),
(16, 14, NULL, '2026-08-21 19:02:00', 'Credit Card', 25.80, 0.00, 'Paid', 'TXN-000016'),
(17, 15, 3, '2026-08-21 20:17:00', 'Gift Card', 9.86, 0.00, 'Paid', 'GC-0003'),
(18, 15, NULL, '2026-08-21 20:18:00', 'Credit Card', 14.80, 2.96, 'Paid', 'TXN-000018'),
(19, 16, NULL, '2026-08-21 21:32:00', 'Mobile Pay', 66.94, 10.04, 'Paid', 'TXN-000019'),
(20, 17, NULL, '2026-08-22 11:47:00', 'Cash', 32.40, 0.00, 'Paid', NULL),
(21, 18, NULL, '2026-08-22 13:02:00', 'Credit Card', 27.50, 0.00, 'Paid', 'TXN-000021'),
(22, 19, NULL, '2026-08-22 14:17:00', 'Debit Card', 49.34, 7.40, 'Paid', 'TXN-000022'),
(23, 20, 4, '2026-08-22 15:32:00', 'Gift Card', 11.66, 0.00, 'Paid', 'GC-0004'),
(24, 20, NULL, '2026-08-22 15:33:00', 'Credit Card', 17.49, 3.50, 'Paid', 'TXN-000024'),
(25, 21, NULL, '2026-08-22 17:47:00', 'Cash', 17.49, 0.00, 'Paid', NULL),
(26, 22, NULL, '2026-08-22 19:02:00', 'Credit Card', 29.59, 4.44, 'Paid', 'TXN-000026'),
(27, 23, NULL, '2026-08-22 20:17:00', 'Debit Card', 58.14, 0.00, 'Paid', 'TXN-000027'),
(28, 24, NULL, '2026-08-22 21:32:00', 'Mobile Pay', 36.25, 0.00, 'Paid', 'TXN-000028'),
(29, 25, 5, '2026-08-23 11:47:00', 'Gift Card', 10.32, 0.00, 'Paid', 'GC-0005'),
(30, 25, NULL, '2026-08-23 11:48:00', 'Credit Card', 15.48, 3.10, 'Paid', 'TXN-000030'),
(31, 26, NULL, '2026-08-23 13:02:00', 'Credit Card', 32.89, 0.00, 'Paid', 'TXN-000031'),
(32, 27, NULL, '2026-08-23 14:17:00', 'Debit Card', 53.85, 0.00, 'Paid', 'TXN-000032'),
(33, 28, NULL, '2026-08-23 15:32:00', 'Mobile Pay', 45.05, 6.76, 'Paid', 'TXN-000033'),
(34, 29, NULL, '2026-08-23 17:47:00', 'Cash', 31.79, 0.00, 'Paid', NULL),
(35, 30, 6, '2026-08-23 19:02:00', 'Gift Card', 7.82, 0.00, 'Paid', 'GC-0006'),
(36, 30, NULL, '2026-08-23 19:03:00', 'Credit Card', 11.72, 2.34, 'Paid', 'TXN-000036'),
(37, 31, NULL, '2026-08-23 20:17:00', 'Debit Card', 38.45, 5.77, 'Paid', 'TXN-000037'),
(38, 32, NULL, '2026-08-23 21:32:00', 'Mobile Pay', 28.55, 0.00, 'Paid', 'TXN-000038'),
(39, 33, NULL, '2026-08-24 11:47:00', 'Cash', 21.40, 0.00, 'Paid', NULL),
(40, 34, 7, '2026-08-24 13:02:00', 'Gift Card', 10.08, 0.00, 'Paid', 'GC-0007'),
(41, 34, NULL, '2026-08-24 13:03:00', 'Credit Card', 15.11, 3.02, 'Paid', 'TXN-000041');

-- Create views

CREATE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.receipt_number,
    o.order_datetime,
    COALESCE(c.customer_name, 'Walk-in') AS customer_name,
    e.employee_name,
    rt.table_number,
    o.order_type,
    o.order_status,
    o.subtotal,
    o.discount_total,
    o.tax_amount,
    o.total_amount
FROM Orders o
LEFT JOIN Customers c
    ON o.customer_id = c.customer_id
JOIN Employees e
    ON o.employee_id = e.employee_id
LEFT JOIN Restaurant_Tables rt
    ON o.table_id = rt.table_id;

CREATE VIEW vw_daily_sales AS
SELECT
    DATE(order_datetime) AS sales_date,
    COUNT(*) AS completed_orders,
    SUM(subtotal) AS subtotal_sales,
    SUM(discount_total) AS discounts_given,
    SUM(tax_amount) AS taxes_collected,
    SUM(total_amount) AS total_sales
FROM Orders
WHERE order_status = 'Completed'
GROUP BY DATE(order_datetime);

-- Sample query 1: Display order summaries with customer, employee, and table information

SELECT
    order_id,
    receipt_number,
    order_datetime,
    customer_name,
    employee_name,
    table_number,
    order_type,
    order_status,
    total_amount
FROM vw_order_summary
ORDER BY order_datetime;

-- Sample query 2: Display every item included in each order

SELECT
    o.order_id,
    o.receipt_number,
    mi.item_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total,
    oi.item_status,
    oi.special_instructions
FROM Orders o
JOIN Order_Items oi
    ON o.order_id = oi.order_id
JOIN Menu_Items mi
    ON oi.menu_item_id = mi.menu_item_id
ORDER BY o.order_id, oi.order_item_id;

-- Sample query 3: Display reservation details with customer and table information

SELECT
    r.reservation_id,
    r.reservation_datetime,
    c.customer_name,
    rt.table_number,
    rt.capacity,
    r.party_size,
    r.reservation_status,
    r.special_request
FROM Reservations r
JOIN Customers c
    ON r.customer_id = c.customer_id
JOIN Restaurant_Tables rt
    ON r.table_id = rt.table_id
ORDER BY r.reservation_datetime;

-- Sample query 4: Calculate completed sales handled by each employee

SELECT
    e.employee_id,
    e.employee_name,
    e.job_title,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(p.payment_amount) AS payments_collected,
    SUM(p.tip_amount) AS tips_received
FROM Employees e
JOIN Orders o
    ON e.employee_id = o.employee_id
JOIN Payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'Completed'
  AND p.payment_status = 'Paid'
GROUP BY e.employee_id, e.employee_name, e.job_title
ORDER BY payments_collected DESC;

-- Sample query 5: Display discounts used on restaurant orders

SELECT
    o.order_id,
    o.receipt_number,
    d.discount_name,
    d.discount_type,
    d.discount_value,
    od.discount_amount
FROM Order_Discounts od
JOIN Orders o
    ON od.order_id = o.order_id
JOIN Discounts d
    ON od.discount_id = d.discount_id
ORDER BY o.order_id;

-- Test the views

SELECT *
FROM vw_order_summary
ORDER BY order_datetime;

SELECT *
FROM vw_daily_sales
ORDER BY sales_date;
