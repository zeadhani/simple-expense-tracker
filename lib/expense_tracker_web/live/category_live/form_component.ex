defmodule ExpenseTrackerWeb.CategoryLive.FormComponent do
  use ExpenseTrackerWeb, :live_component

  alias ExpenseTracker.Expenses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-2xl p-8 max-w-lg mx-auto">
      <div class="text-center mb-8">
        <div class="w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full flex items-center justify-center mx-auto mb-4">
          <.icon name="hero-folder-plus" class="w-8 h-8 text-white" />
        </div>
        <h2 class="text-2xl font-bold text-gray-900 mb-2"><%= @title %></h2>
        <p class="text-gray-600">Create and manage your expense categories with monthly budgets</p>
      </div>

      <.form
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
      >
        <div class="space-y-2">
          <.input 
            field={@form[:name]} 
            type="text" 
            label="Category Name" 
            placeholder="e.g., Food & Dining, Transportation"
            required 
          />
          
          <.input 
            field={@form[:description]} 
            type="textarea" 
            label="Description (Optional)" 
            placeholder="Brief description of what this category includes..."
            rows="3"
          />
          
          <.input 
            field={@form[:monthly_budget_cents]} 
            type="number" 
            label="Monthly Budget (cents)" 
            placeholder="50000"
            min="1"
            max="10000000"
            required 
          />
          <p class="text-sm text-gray-500 -mt-2 flex items-center">
            <.icon name="hero-information-circle" class="w-4 h-4 mr-1" />
            Enter amount in cents (e.g., 50000 = $500.00)
          </p>
        </div>
        
        <div class="flex items-center justify-end space-x-3 pt-6 border-t border-gray-100">
          <button 
            type="button"
            phx-click={JS.exec("data-cancel", to: "#category-modal")}
            class="px-6 py-3 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-xl font-medium transition-all duration-200"
          >
            Cancel
          </button>
          <button 
            type="submit"
            phx-disable-with="Saving..." 
            disabled={!@form.source.valid?}
            class={[
              "px-8 py-3 rounded-xl font-semibold shadow-lg transition-all duration-200",
              if(@form.source.valid?, 
                do: "btn-gradient hover:shadow-xl", 
                else: "bg-gray-300 text-gray-500 cursor-not-allowed")
            ]}
          >
            <%= if @action == :edit, do: "Update Category", else: "Create Category" %>
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset = Expenses.change_category(category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Expenses.change_category(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    case Expenses.update_category(socket.assigns.category, category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_category(socket, :new, category_params) do
    case Expenses.create_category(category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end