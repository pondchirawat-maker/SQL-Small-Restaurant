# Database Design Explanation

## Final Scope
The database is for **one small restaurant**, not a restaurant chain and not a full accounting/ERP system.

The project proposal requires the restaurant to manage:
- customers
- menu items and prices
- customer orders
- reservations
- employees
- employee schedules
- payments
- discounts
- table numbers
- order status
- special instructions
- taxes
- receipts

The final design uses 12 tables.

## Tables

### 1. Customers
Stores identifiable customer information. Orders may have a NULL customer_id because walk-in customers do not always provide personal information.

### 2. Employees
Stores restaurant workers and their roles. Former employees can remain as Inactive records so historical orders still reference a valid employee.

### 3. Employee_Shifts
Stores the employee schedule requested by the manager stakeholder. A shift belongs to one employee, while an employee can have many shifts.

### 4. Restaurant_Tables
Stores the actual physical tables, table numbers, capacity, section, and current status. This prevents table numbers from being repeated as uncontrolled text.

### 5. Reservations
Connects a customer to a restaurant table for a specific date/time and party size.

### 6. Menu_Items
Stores the current menu, category, price, and availability.

### 7. Orders
Stores the overall restaurant transaction. It tracks customer, server, table, date/time, order type, current status, subtotal, discounts, tax, final total, closing time, and receipt number.

### 8. Order_Items
Stores each menu item ordered. The unit_price is saved at the time of the sale so old receipts remain correct even if the menu price changes later. It also stores special instructions and remake/comp reasons.

### 9. Discounts
Stores the small number of discount rules used by the restaurant.

### 10. Order_Discounts
Connects actual orders to the discounts that were used and stores the dollar amount applied.

### 11. Gift_Cards
Tracks gift-card codes, original values, and current balances. A separate table is necessary because one gift card may be used over multiple visits.

### 12. Payments
Stores each payment made toward an order. One order can have multiple payment rows, which supports split checks/payments. It also records tips and card/gift-card references.

## Important Relationships
- Customers 1:N Orders
- Customers 1:N Reservations
- Employees 1:N Employee_Shifts
- Employees 1:N Orders
- Restaurant_Tables 1:N Reservations
- Restaurant_Tables 1:N Orders
- Orders 1:N Order_Items
- Menu_Items 1:N Order_Items
- Orders 1:N Order_Discounts
- Discounts 1:N Order_Discounts
- Orders 1:N Payments
- Gift_Cards 1:N Payments

## Why Vendors, Inventory, Expenses, and Payroll Are Not Included
They are legitimate restaurant functions, but they are not part of the submitted requirements. Adding them would change the project from a restaurant-service and order-management database into a purchasing/accounting system. Those features are better listed as future expansion.

## Sample Data Strategy
The assignment suggests approximately 40 sample rows for each table. For transactional tables, a sample around 40 or more makes sense. For master/reference tables, blindly creating 40 rows would make the data unrealistic for a small restaurant.

This dataset therefore uses:
- 40 customers
- 13 employee records, with 11 currently active
- 40 employee shifts
- 12 physical restaurant tables
- 24 reservations
- 32 menu items
- 40 orders
- multiple order items per order
- 6 discount programs
- only the order-discount records actually used
- 12 gift cards
- payments corresponding to completed orders, including split payments

This preserves the purpose of sample data while keeping the fictional business believable.
