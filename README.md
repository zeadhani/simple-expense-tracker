# Expense Tracker

A Phoenix-based web application for tracking personal expenses. This application allows users to manage their expenses by categorizing them and setting monthly budgets.

## Features

- **Expense Management:** Create, edit expenses.
- **Category Management:** Organize expenses into categories with monthly budgets.
- **Dashboard:**
  - View total monthly budget and total spending at a glance.
  - See a list of recent expenses.
  - Track spending per category with progress bars to visualize budget usage.
  - A 7-day chart showing daily spending.
- **Currency Formatting:** Uses `ex_cldr` to format monetary values correctly.

## Technology Stack

- **Backend:** Elixir, Phoenix Framework
- **Frontend:** Phoenix LiveView, Tailwind CSS, DaisyUI
- **Database:** PostgreSQL
- **Testing:** ExUnit, Floki
- **Email:** Swoosh
- **Asset Bundling:** esbuild

## Getting Started

To get the application running locally:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/zeadhani/Simple-expense-tracker.git
    cd expense_tracker
    ```

2.  **Install dependencies:**
    ```bash
    mix setup
    ```
    This will install all Elixir and frontend dependencies.

3.  **Set up the database:**
    Make sure you have PostgreSQL installed and running. You may need to configure your database credentials in `config/dev.exs`. Then, run:
    ```bash
    mix ecto.setup
    ```
    This will create the database, run the migrations, and seed the database with initial data.

4.  **Start the Phoenix server:**
    ```bash
    mix phx.server
    ```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Database Schema

The application uses the following database tables:

- `categories`: Stores expense categories.
  - `name`: string
  - `description`: string
  - `monthly_budget_cents`: integer
- `expenses`: Stores individual expenses.
  - `description`: string
  - `amount_cents`: integer
  - `date`: date
  - `notes`: string
  - `category_id`: foreign key to `categories`

## Application Routes

The main routes for the application are:

- `/`: The main dashboard.
- `/categories`: Lists all categories.
- `/categories/new`: Form to create a new category.
- `/categories/:id`: Shows a single category and its associated expenses.
- `/categories/:id/edit`: Form to edit a category.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
