defmodule ExpenseTracker.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :description, :string
    field :amount_cents, :integer
    field :date, :date
    field :notes, :string

    belongs_to :category, ExpenseTracker.Expenses.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:description, :amount_cents, :date, :notes, :category_id])
    |> validate_required([:description, :amount_cents, :date, :category_id])
    |> validate_length(:description, min: 1, max: 255)
    |> validate_amount_cents()
    |> validate_date_not_future()
    |> foreign_key_constraint(:category_id)
  end

  defp validate_amount_cents(changeset) do
    validate_number(changeset, :amount_cents, greater_than: 0, less_than_or_equal_to: 10_000_000)
  end

  defp validate_date_not_future(changeset) do
    case get_field(changeset, :date) do
      nil -> changeset
      date ->
        today = Date.utc_today()
        if Date.compare(date, today) == :gt do
          add_error(changeset, :date, "cannot be in the future")
        else
          changeset
        end
    end
  end
end
