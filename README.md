# 📚 Bookshop Management System

## 📌 Project Overview

The **Bookshop Management System** is a beginner-level SQL database project developed using MySQL. The project is designed to manage the daily operations of a bookshop, including book inventory, customer details, order processing and sales reporting.

It demonstrates how relational databases and SQL operations can be used to organise data, automate inventory management and generate useful business reports.

## 🎯 Project Objectives

- Manage book categories and book information.
- Maintain customer records.
- Process orders containing multiple books.
- Automatically update book stock after sales.
- Prevent sales when available stock is insufficient.
- Maintain a record of book price changes.
- Generate sales and customer reports.

## 🗂️ Database Structure

**Database Name:** `bookshop_db`

The database contains five main tables:

| Table Name | Description |
|---|---|
| `categories` | Stores different book categories. |
| `books` | Stores book names, authors, prices and stock quantities. |
| `customers` | Stores customer information. |
| `orders` | Stores customer order details. |
| `order_items` | Stores individual books included in each order. |

## 🔗 Database Relationships

- One category can contain multiple books.
- One customer can place multiple orders.
- One order can contain multiple books.
- One book can appear in multiple orders.

Primary keys and foreign keys are used to establish relationships between the tables.

## ⚙️ SQL Concepts Used

### 1. Database Operations
- CREATE DATABASE
- CREATE TABLE
- INSERT
- UPDATE
- DELETE
- SELECT

### 2. Views

**View Name:** `v_order_summary`

This view displays order information along with customer names and calculated order totals using JOIN operations.

### 3. Triggers

The project includes three trigger operations:

- **Stock Reduction:** Automatically reduces book stock after a sale.
- **Stock Validation:** Prevents a sale if the available stock is insufficient.
- **Price Change Log:** Records old prices, new prices and the date of price changes.

### 4. Transaction Management

Transactions are used to process orders containing multiple books.

- START TRANSACTION
- COMMIT
- ROLLBACK

If all order items are processed successfully, the transaction is committed. If any item fails, the transaction is rolled back to maintain data consistency.

### 5. Business Reports

The project generates three important business reports:

| Report | Purpose |
|---|---|
| Monthly Revenue | Calculates total sales for each month. |
| Best-Selling Books | Identifies books with the highest sales quantities. |
| Top Customers | Identifies customers with the highest spending. |

### 6. Data Import and Export

- Import new book records from CSV files using `LOAD DATA INFILE`.
- Export the complete book catalogue using `SELECT INTO OUTFILE`.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---
