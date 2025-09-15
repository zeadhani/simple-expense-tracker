defmodule ExpenseTracker.Expenses.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :monthly_budget_cents, :integer

    has_many :expenses, ExpenseTracker.Expenses.Expense

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :monthly_budget_cents])
    |> validate_required([:name, :monthly_budget_cents])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, max: 500)
    |> validate_budget_amount()
    |> unique_constraint(:name, message: "Category name must be unique")
  end

  defp validate_budget_amount(changeset) do
    validate_number(changeset, :monthly_budget_cents, greater_than: 0, less_than_or_equal_to: 100_000_000)
  end
end
