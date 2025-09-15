defmodule ExpenseTrackerWeb.DashboardLive do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses

  @impl true
  def mount(_params, _session, socket) do
    categories = Expenses.list_categories()
    total_budget = Enum.sum(Enum.map(categories, & &1.monthly_budget_cents))
    total_spent = Enum.sum(Enum.map(categories, &Expenses.get_category_total_spent(&1.id)))
    
    recent_expenses = Expenses.list_expenses() 
                     |> Enum.sort_by(& &1.date, {:desc, Date})
                     |> Enum.take(5)
    
    budget_categories = Enum.map(categories, fn category ->
      spent = Expenses.get_category_total_spent(category.id)
      percentage = Expenses.get_spending_percentage(category)
      
      %{
        name: category.name,
        spent: spent,
        budget: category.monthly_budget_cents,
        percentage: percentage,
        status: cond do
          percentage > 100 -> :over_budget
          percentage > 80 -> :warning
          true -> :safe
        end
      }
    end)
    |> Enum.sort_by(& &1.percentage, :desc)

    spending_by_day = get_spending_by_day()
    
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:total_budget, total_budget)
     |> assign(:total_spent, total_spent)
     |> assign(:budget_percentage, calculate_budget_percentage(total_spent, total_budget))
     |> assign(:recent_expenses, recent_expenses)
     |> assign(:budget_categories, budget_categories)
     |> assign(:spending_by_day, spending_by_day)
     |> assign(:categories_count, length(categories))}
  end

  defp calculate_budget_percentage(spent, budget) when budget > 0 do
    (spent / budget * 100) |> Float.round(1)
  end
  defp calculate_budget_percentage(_spent, _budget), do: 0.0

  defp get_spending_by_day do
    today = Date.utc_today()
    
    for i <- 6..0//-1 do
      date = Date.add(today, -i)
      expenses = Expenses.list_expenses()
                |> Enum.filter(&(Date.compare(&1.date, date) == :eq))
      total = Enum.sum(Enum.map(expenses, & &1.amount_cents))
      
      %{
        date: date,
        total: total,
        day_name: Calendar.strftime(date, "%a")
      }
    end
  end

  defp format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end
end