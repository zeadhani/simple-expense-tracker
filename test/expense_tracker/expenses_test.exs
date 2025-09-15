defmodule ExpenseTracker.ExpensesTest do
  use ExpenseTracker.DataCase

  alias ExpenseTracker.Expenses

  describe "categories" do
    alias ExpenseTracker.Expenses.Category

    import ExpenseTracker.ExpensesFixtures

    @invalid_attrs %{name: nil, description: nil, monthly_budget_cents: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Expenses.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Expenses.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name", description: "some description", monthly_budget_cents: 42}

      assert {:ok, %Category{} = category} = Expenses.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some description"
      assert category.monthly_budget_cents == 42
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Expenses.create_category(@invalid_attrs)
    end

    test "create_category/1 with negative budget returns error changeset" do
      invalid_attrs = %{name: "test", monthly_budget_cents: -100}
      assert {:error, %Ecto.Changeset{}} = Expenses.create_category(invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", monthly_budget_cents: 43}

      assert {:ok, %Category{} = category} = Expenses.update_category(category, update_attrs)
      assert category.name == "some updated name"
      assert category.description == "some updated description"
      assert category.monthly_budget_cents == 43
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Expenses.update_category(category, @invalid_attrs)
      assert category == Expenses.get_category!(category.id)
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Expenses.change_category(category)
    end
  end

  describe "expenses" do
    alias ExpenseTracker.Expenses.Expense

    import ExpenseTracker.ExpensesFixtures

    @invalid_attrs %{description: nil, amount_cents: nil, date: nil, notes: nil}

    test "list_expenses/0 returns all expenses" do
      expense = expense_fixture()
      [loaded_expense] = Expenses.list_expenses()
      assert loaded_expense.id == expense.id
      assert loaded_expense.category.id == expense.category_id
    end

    test "get_expense!/1 returns the expense with given id" do
      expense = expense_fixture()
      assert Expenses.get_expense!(expense.id).id == expense.id
    end

    test "create_expense/1 with valid data creates an expense" do
      category = category_fixture()
      valid_attrs = %{description: "some description", amount_cents: 42, date: ~D[2025-09-14], notes: "some notes", category_id: category.id}

      assert {:ok, %Expense{} = expense} = Expenses.create_expense(valid_attrs)
      assert expense.description == "some description"
      assert expense.amount_cents == 42
      assert expense.date == ~D[2025-09-14]
      assert expense.notes == "some notes"
      assert expense.category_id == category.id
    end

    test "create_expense/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(@invalid_attrs)
    end

    test "create_expense/1 with negative amount returns error changeset" do
      category = category_fixture()
      invalid_attrs = %{description: "test", amount_cents: -100, date: ~D[2025-09-14], category_id: category.id}
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(invalid_attrs)
    end

    test "create_expense/1 with future date returns error changeset" do
      category = category_fixture()
      future_date = Date.add(Date.utc_today(), 1)
      invalid_attrs = %{description: "test", amount_cents: 1000, date: future_date, category_id: category.id}
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(invalid_attrs)
    end

    test "create_expense/1 with amount above maximum returns error changeset" do
      category = category_fixture()
      invalid_attrs = %{description: "test", amount_cents: 10_000_001, date: ~D[2025-09-14], category_id: category.id}
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(invalid_attrs)
    end

    test "create_expense/1 with missing category_id returns error changeset" do
      invalid_attrs = %{description: "test", amount_cents: 1000, date: ~D[2025-09-14]}
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(invalid_attrs)
    end

    test "update_expense/2 with valid data updates the expense" do
      expense = expense_fixture()
      update_attrs = %{description: "some updated description", amount_cents: 43, date: ~D[2025-09-15], notes: "some updated notes"}

      assert {:ok, %Expense{} = expense} = Expenses.update_expense(expense, update_attrs)
      assert expense.description == "some updated description"
      assert expense.amount_cents == 43
      assert expense.date == ~D[2025-09-15]
      assert expense.notes == "some updated notes"
    end

    test "update_expense/2 with invalid data returns error changeset" do
      expense = expense_fixture()
      assert {:error, %Ecto.Changeset{}} = Expenses.update_expense(expense, @invalid_attrs)
      assert expense.id == Expenses.get_expense!(expense.id).id
    end

    test "change_expense/1 returns an expense changeset" do
      expense = expense_fixture()
      assert %Ecto.Changeset{} = Expenses.change_expense(expense)
    end
  end

  describe "money handling" do
    test "format_money/1 formats cents to dollar string" do
      assert Expenses.format_money(1234) == "$12.34"
      assert Expenses.format_money(100) == "$1.00"
      assert Expenses.format_money(5) == "$0.05"
      assert Expenses.format_money(nil) == "$0.00"
    end

    test "format_money/1 handles edge cases" do
      assert Expenses.format_money(0) == "$0.00"
      assert Expenses.format_money(10000000) == "$100,000.00"
    end
  end

  describe "spending calculations" do
    import ExpenseTracker.ExpensesFixtures

    test "get_category_total_spent/1 returns total spent for category" do
      category = category_fixture()
      _expense1 = expense_fixture(%{category_id: category.id, amount_cents: 1000})
      _expense2 = expense_fixture(%{category_id: category.id, amount_cents: 2000})

      assert Expenses.get_category_total_spent(category.id) == 3000
    end

    test "get_spending_percentage/1 calculates percentage correctly" do
      category = category_fixture(%{monthly_budget_cents: 10000})
      _expense = expense_fixture(%{category_id: category.id, amount_cents: 2500})

      assert Expenses.get_spending_percentage(category) == 25.0
    end

    test "get_spending_percentage/1 handles over budget" do
      category = category_fixture(%{monthly_budget_cents: 10000})
      _expense = expense_fixture(%{category_id: category.id, amount_cents: 15000})

      assert Expenses.get_spending_percentage(category) == 150.0
    end

    test "get_spending_percentage/1 handles zero budget correctly" do
      category = category_fixture(%{monthly_budget_cents: 1})
      category = %{category | monthly_budget_cents: 0}
      
      assert Expenses.get_spending_percentage(category) == 0.0
    end

    test "get_category_total_spent/1 returns 0 for category with no expenses" do
      category = category_fixture()
      assert Expenses.get_category_total_spent(category.id) == 0
    end

    test "get_category_total_spent/1 only counts expenses for specific category" do
      category1 = category_fixture()
      category2 = category_fixture()
      _expense1 = expense_fixture(%{category_id: category1.id, amount_cents: 1000})
      _expense2 = expense_fixture(%{category_id: category2.id, amount_cents: 2000})

      assert Expenses.get_category_total_spent(category1.id) == 1000
      assert Expenses.get_category_total_spent(category2.id) == 2000
    end
  end
end