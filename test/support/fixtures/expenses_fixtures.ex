defmodule ExpenseTracker.ExpensesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExpenseTracker.Expenses` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        monthly_budget_cents: 42000,
        name: "some name"
      })
      |> ExpenseTracker.Expenses.create_category()

    category
  end

  @doc """
  Generate a expense.
  """
  def expense_fixture(attrs \\ %{}) do
    category = Map.get_lazy(attrs, :category_id, fn -> category_fixture().id end)

    {:ok, expense} =
      attrs
      |> Enum.into(%{
        amount_cents: 4200,
        date: ~D[2025-09-14],
        description: "some description",
        notes: "some notes",
        category_id: category
      })
      |> ExpenseTracker.Expenses.create_expense()

    expense
  end
end