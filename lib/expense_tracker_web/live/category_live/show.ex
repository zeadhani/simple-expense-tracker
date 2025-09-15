defmodule ExpenseTrackerWeb.CategoryLive.Show do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses
  alias ExpenseTracker.Expenses.Expense
  alias ExpenseTracker.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    category = Expenses.get_category_with_expenses!(id)
    expense_changeset = Expenses.change_expense(%Expense{}, %{date: Date.utc_today()})
    
    spent = Expenses.get_category_total_spent(category.id)
    percentage = Expenses.get_spending_percentage(category)
    
    {:noreply,
     socket
     |> assign(:page_title, category.name)
     |> assign(:category, category)
     |> assign(:expense, %Expense{})
     |> assign(:expense_form, to_form(expense_changeset))
     |> assign(:spent, spent)
     |> assign(:percentage, percentage)
     |> stream(:expenses, category.expenses,reset: true)}
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    expense_params_with_category = Map.put(expense_params, "category_id", socket.assigns.category.id)
    
    changeset =
      %Expense{}
      |> Expenses.change_expense(expense_params_with_category)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :expense_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"expense" => expense_params}, socket) do
    expense_params_with_category = Map.put(expense_params, "category_id", socket.assigns.category.id)
    
    case Expenses.create_expense(expense_params_with_category) do
      {:ok, expense} ->
        expense = Repo.preload(expense, :category)
        updated_category = Expenses.get_category_with_expenses!(socket.assigns.category.id)
        
        spent = Expenses.get_category_total_spent(updated_category.id)
        percentage = Expenses.get_spending_percentage(updated_category)
        
        {:noreply,
         socket
         |> assign(:category, updated_category)
         |> assign(:expense, %Expense{})
         |> assign(:expense_form, to_form(Expenses.change_expense(%Expense{}, %{date: Date.utc_today()})))
         |> assign(:spent, spent)
         |> assign(:percentage, percentage)
         |> stream_insert(:expenses, expense, at: 0)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :expense_form, to_form(changeset))}
    end
  end


  defp format_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end
end