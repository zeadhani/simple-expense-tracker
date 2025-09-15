defmodule ExpenseTrackerWeb.CategoryLiveTest do
  use ExpenseTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import ExpenseTracker.ExpensesFixtures

  @create_attrs %{name: "some name", description: "some description", monthly_budget_cents: 42000}
  @update_attrs %{name: "some updated name", description: "some updated description", monthly_budget_cents: 43000}
  @invalid_attrs %{name: nil, description: nil, monthly_budget_cents: nil}

  defp create_category(_) do
    category = category_fixture()
    %{category: category}
  end

  describe "Index" do
    setup [:create_category]

    test "lists all categories", %{conn: conn, category: category} do
      {:ok, _index_live, html} = live(conn, ~p"/categories")

      assert html =~ "Budget Categories"
      assert html =~ category.name
    end

    test "saves new category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/categories/new")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#category-form", category: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "some name"
    end

    test "updates category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a[href='/categories/#{category.id}/edit']") |> render_click() =~
               "Edit Category"

      assert_patch(index_live, ~p"/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#category-form", category: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "some updated name"
    end
  end

  describe "Show" do
    setup [:create_category]

    test "displays category", %{conn: conn, category: category} do
      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ category.name
      assert html =~ category.description
    end

    test "creates new expense", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert show_live
             |> form("#expense-form", expense: %{description: "Test expense", amount_cents: 1500, date: "2025-09-15", notes: "Test notes"})
             |> render_submit()

      html = render(show_live)
      assert html =~ "Test expense"
      assert html =~ "$15.00"
    end

    test "validates expense form", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert show_live
             |> form("#expense-form", expense: %{description: "", amount_cents: -100, date: "", notes: ""})
             |> render_change() =~ "can&#39;t be blank"
    end

    test "updates spending totals when expense is added", %{conn: conn, category: category} do
      {:ok, show_live, html} = live(conn, ~p"/categories/#{category}")
      
      assert html =~ "$0.00"
      
      assert show_live
             |> form("#expense-form", expense: %{description: "Test expense", amount_cents: 1000, date: "2025-09-15", notes: ""})
             |> render_submit()

      html = render(show_live)
      assert html =~ "$10.00"
    end

    test "displays budget percentage correctly", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")
      
      assert show_live
             |> form("#expense-form", expense: %{description: "Half budget", amount_cents: 21000, date: "2025-09-15", notes: ""})
             |> render_submit()

      html = render(show_live)
      assert html =~ "50.0%"
    end

    test "shows over budget warning when expenses exceed budget", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")
      
      assert show_live
             |> form("#expense-form", expense: %{description: "Over budget", amount_cents: 50000, date: "2025-09-15", notes: ""})
             |> render_submit()

      html = render(show_live)
      assert html =~ "Budget Exceeded"
    end

    test "prevents adding expense with invalid data", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")
      
      html = show_live
             |> form("#expense-form", expense: %{description: "", amount_cents: "", date: "", notes: ""})
             |> render_submit()
      
      assert html =~ "can&#39;t be blank"
    end
  end

  describe "Dashboard" do
    test "displays dashboard with categories", %{conn: conn} do
      _category = category_fixture()
      {:ok, _dashboard_live, html} = live(conn, ~p"/")
      
      assert html =~ "Financial Dashboard"
      assert html =~ "Total Budget"
      assert html =~ "Categories"
    end

    test "shows recent expenses on dashboard", %{conn: conn} do
      category = category_fixture()
      expense_fixture(%{category_id: category.id, description: "Test expense"})
      
      {:ok, _dashboard_live, html} = live(conn, ~p"/")
      
      assert html =~ "Recent Expenses"
      assert html =~ "Test expense"
    end
  end
end