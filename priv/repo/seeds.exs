alias ExpenseTracker.Repo
alias ExpenseTracker.Expenses.{Category, Expense}

food_category = Repo.insert!(%Category{
  name: "Food & Dining",
  description: "Groceries, restaurants, and food delivery",
  monthly_budget_cents: 50000
})

transportation_category = Repo.insert!(%Category{
  name: "Transportation",
  description: "Gas, public transit, rideshare, and car maintenance",
  monthly_budget_cents: 30000
})

entertainment_category = Repo.insert!(%Category{
  name: "Entertainment",
  description: "Movies, concerts, streaming services, and hobbies",
  monthly_budget_cents: 20000
})

utilities_category = Repo.insert!(%Category{
  name: "Utilities",
  description: "Internet, phone, electricity, water, and gas bills",
  monthly_budget_cents: 25000
})

food_expenses = [
  %{description: "Grocery shopping at Whole Foods", amount_cents: 8750, date: ~D[2025-09-14], notes: "Weekly grocery run"},
  %{description: "Coffee at local cafe", amount_cents: 450, date: ~D[2025-09-13], notes: ""},
  %{description: "Lunch with friends", amount_cents: 2800, date: ~D[2025-09-12], notes: "Italian restaurant downtown"},
  %{description: "Pizza delivery", amount_cents: 1650, date: ~D[2025-09-10], notes: "Friday night dinner"}
]

transportation_expenses = [
  %{description: "Gas fill-up", amount_cents: 4200, date: ~D[2025-09-14], notes: "Shell station on Main St"},
  %{description: "Metro card refill", amount_cents: 2000, date: ~D[2025-09-11], notes: "Monthly transit pass"},
  %{description: "Uber ride home", amount_cents: 1250, date: ~D[2025-09-09], notes: "Late night from downtown"}
]

entertainment_expenses = [
  %{description: "Movie tickets", amount_cents: 1800, date: ~D[2025-09-13], notes: "New Marvel movie"},
  %{description: "Spotify subscription", amount_cents: 1099, date: ~D[2025-09-01], notes: "Monthly subscription"},
  %{description: "Book purchase", amount_cents: 1595, date: ~D[2025-09-08], notes: "Programming book from Amazon"}
]

utilities_expenses = [
  %{description: "Internet bill", amount_cents: 7999, date: ~D[2025-09-01], notes: "Comcast monthly bill"},
  %{description: "Phone bill", amount_cents: 5500, date: ~D[2025-09-01], notes: "Verizon monthly plan"},
  %{description: "Electricity bill", amount_cents: 9200, date: ~D[2025-09-03], notes: "Higher usage due to AC"}
]

for expense_data <- food_expenses do
  Repo.insert!(%Expense{
    description: expense_data.description,
    amount_cents: expense_data.amount_cents,
    date: expense_data.date,
    notes: expense_data.notes,
    category_id: food_category.id
  })
end

for expense_data <- transportation_expenses do
  Repo.insert!(%Expense{
    description: expense_data.description,
    amount_cents: expense_data.amount_cents,
    date: expense_data.date,
    notes: expense_data.notes,
    category_id: transportation_category.id
  })
end

for expense_data <- entertainment_expenses do
  Repo.insert!(%Expense{
    description: expense_data.description,
    amount_cents: expense_data.amount_cents,
    date: expense_data.date,
    notes: expense_data.notes,
    category_id: entertainment_category.id
  })
end

for expense_data <- utilities_expenses do
  Repo.insert!(%Expense{
    description: expense_data.description,
    amount_cents: expense_data.amount_cents,
    date: expense_data.date,
    notes: expense_data.notes,
    category_id: utilities_category.id
  })
end

IO.puts("Database seeded successfully!")
IO.puts("Created #{Repo.aggregate(Category, :count, :id)} categories")
IO.puts("Created #{Repo.aggregate(Expense, :count, :id)} expenses")
