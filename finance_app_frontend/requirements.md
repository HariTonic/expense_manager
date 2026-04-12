# Expense Manager App – Requirements Document

## 1. Introduction

The Expense Manager App is a mobile application designed to help users track, manage, and analyze their personal income and expenses efficiently. The app provides a simple and intuitive interface to record financial transactions, categorize spending, and visualize financial habits over time.

## 2. Objective

The primary objectives of this application are:

- To enable users to track daily income and expenses.
- To categorize transactions for better financial understanding.
- To provide insights through summaries and reports.
- To ensure data persistence with offline support.
- To optionally back up data using cloud storage (Google Drive).

## 3. Target Users

- Students managing pocket money.
- Working professionals tracking monthly expenses.
- Freelancers managing income and expenses.
- Anyone interested in personal finance tracking.

## 4. Scope of the Application

The application will include:

- Expense tracking
- Income tracking
- Category management
- Monthly summaries
- Offline data storage
- Optional login and cloud backup

Out of scope (for initial version):

- Bank integration
- Real-time transaction sync with banks
- Investment tracking

## 5. Key Features

### 5.1 User Authentication (Optional)

- Login using Google or email (optional feature).
- Guest mode support without login.
- If logged in, enable cloud backup.

### 5.2 Expense Management

- Add new expense
- Edit existing expense
- Delete expense

Fields:
- Title (e.g., Groceries, Rent)
- Amount
- Date
- Category
- Notes (optional)

### 5.3 Income Management

- Add income entries
- Edit income entries
- Delete income entries

Fields:
- Source (e.g., Salary, Freelance)
- Amount
- Date
- Notes (optional)

### 5.4 Categories

Predefined categories:
- Food
- Transport
- Shopping
- Bills
- Entertainment
- Health
- User-defined custom categories

### 5.5 Dashboard (Home Screen)

- Display total balance
- Monthly income summary
- Monthly expense summary
- Recent transactions list
- Quick add buttons (Income / Expense)

### 5.6 Reports & Analytics

- Monthly expense breakdown (pie chart)
- Category-wise spending
- Income vs expense comparison
- Daily/weekly trends

### 5.7 Search & Filters

Search transactions by title

Filter by:
- Date range
- Category
- Income/Expense type

### 5.8 Offline Storage

- Use local database (Hive)
- All data stored locally by default
- Fast read/write operations

### 5.9 Cloud Backup (Optional)

- Backup data to Google Drive
- Restore data from backup
- Sync only when user is logged in

## 6. Technical Architecture

### 6.1 Frontend

- Flutter (Cross-platform mobile app)

### 6.2 Backend (Python-Based Architecture)

The backend will be implemented using Python to ensure scalability, simplicity, and strong support for APIs and data processing.

Backend Responsibilities:
- User authentication (login/logout, session/token management)
- Manage income and expense data via APIs
- Cloud backup and restore functionality
- Sync data across multiple devices
- Provide analytics and summary endpoints

Recommended Backend Stack:
- Python FastAPI (high-performance API framework)
- Uvicorn (ASGI server)

Database Options:
- PostgreSQL (recommended for structured financial data)
- SQLite (for initial development / local testing)

Authentication:
- JWT (JSON Web Tokens)
- Optional OAuth2 (Google login integration in future)

Cloud Storage:
- Google Drive API / AWS S3 (for backups)

API Design (Sample Endpoints):
- POST /auth/register
- POST /auth/login
- GET /transactions
- POST /transactions
- PUT /transactions/{id}
- DELETE /transactions/{id}
- GET /summary/monthly

### 6.3 State Management

- Provider / Riverpod / Bloc (to be decided)

### 6.4 Local Database

- Hive (NoSQL lightweight storage)

### 6.5 Cloud Storage

- Google Drive API (optional backup feature)

### 6.6 Architecture Pattern

- MVVM or Clean Architecture

## 7. Data Models

### 7.1 Expense Model

- id (String)
- title (String)
- amount (double)
- date (DateTime)
- category (String)
- note (String)

### 7.2 Income Model

- id (String)
- source (String)
- amount (double)
- date (DateTime)
- note (String)

### 7.3 Category Model

- id (String)
- name (String)
- type (income/expense)

## 8. UI Screens

### 8.1 Splash Screen

- App logo
- Initialization loading

### 8.2 Home Screen

- Balance overview
- Income/Expense summary
- Recent transactions

### 8.3 Add Expense Screen

- Form inputs
- Category selector
- Save button

### 8.4 Add Income Screen

- Form inputs
- Save button

### 8.5 Reports Screen

- Charts and analytics

### 8.6 Settings Screen

- Backup/restore
- Categories management
- App preferences

## 9. Non-Functional Requirements

- Fast performance (under 2 seconds screen load)
- Offline-first architecture
- Secure local storage
- Scalable architecture for future enhancements
- Simple and intuitive UI/UX

## 10. Future Enhancements

- AI-based spending insights
- Budget planning alerts
- OCR-based bill scanning
- Multi-device sync
- Export to Excel/PDF

## 11. Assumptions

- Users have smartphones with Flutter-supported OS
- Internet required only for backup feature
- Local storage is primary data source

## 12. Conclusion

This Expense Manager App aims to provide a lightweight, fast, and user-friendly solution for personal finance tracking with offline-first capability and optional cloud backup support.
