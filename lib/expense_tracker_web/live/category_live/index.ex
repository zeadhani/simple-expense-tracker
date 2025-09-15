defmodule ExpenseTrackerWeb.CategoryLive.Index do
  use ExpenseTrackerWeb, :live_view

  alias ExpenseTracker.Expenses
  alias ExpenseTracker.Expenses.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      if not Map.has_key?(socket.assigns, :streams) or
           not Map.has_key?(socket.assigns.streams, :categories) do
        load_categories(socket)
      else
        socket
      end

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp load_categories(socket) do
    categories = Expenses.list_categories()

    categories_with_spending =
      Enum.map(categories, fn category ->
        spent = Expenses.get_category_total_spent(category.id)
        percentage = Expenses.get_spending_percentage(category)
        Map.merge(category, %{spent: spent, percentage: percentage})
      end)

    stream(socket, :categories, categories_with_spending, reset: true)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Expenses.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Categories")
    |> assign(:category, nil)
  end

  @impl true
  def handle_info({ExpenseTrackerWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    spent = Expenses.get_category_total_spent(category.id)
    percentage = Expenses.get_spending_percentage(category)
    category_with_spending = Map.merge(category, %{spent: spent, percentage: percentage})

    {:noreply,
     socket
     |> stream_insert(:categories, category_with_spending)
     |> push_patch(to: ~p"/categories")}
  end
end
