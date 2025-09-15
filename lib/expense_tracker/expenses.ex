defmodule ExpenseTracker.Expenses do
  import Ecto.Query, warn: false
  alias ExpenseTracker.Repo

  alias ExpenseTracker.Expenses.Category
  alias ExpenseTracker.Expenses.Expense

  def list_categories do
    Repo.all(Category)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def get_category_with_expenses!(id) do
    Category
    |> Repo.get!(id)
    |> Repo.preload(expenses: from(e in Expense, order_by: [desc: e.date]))
  end

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  def list_expenses do
    Expense
    |> Repo.all()
    |> Repo.preload(:category)
  end

  def get_expense!(id), do: Repo.get!(Expense, id)

  def create_expense(attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end

  def get_category_total_spent(category_id) do
    from(e in Expense, where: e.category_id == ^category_id, select: sum(e.amount_cents))
    |> Repo.one()
    |> case do
      nil -> 0
      total -> total
    end
  end

  def get_spending_percentage(category) do
    total_spent = get_category_total_spent(category.id)
    if category.monthly_budget_cents > 0 do
      (total_spent / category.monthly_budget_cents * 100) |> Float.round(1)
    else
      0.0
    end
  end

  def format_money(cents) when is_integer(cents) do
    amount = Decimal.new(cents) |> Decimal.div(100)
    
    case ExpenseTracker.Cldr.Number.to_string(amount, currency: :USD) do
      {:ok, formatted} -> formatted
      _error -> "$0.00"
    end
  end

  def format_money(nil), do: "$0.00"

end