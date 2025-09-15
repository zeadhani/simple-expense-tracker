defmodule ExpenseTrackerWeb.Router do
  use ExpenseTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExpenseTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExpenseTrackerWeb do
    pipe_through :browser

    live "/", DashboardLive, :index
    live "/categories", CategoryLive.Index, :index
    live "/categories/new", CategoryLive.Index, :new
    live "/categories/:id/edit", CategoryLive.Index, :edit
    live "/categories/:id", CategoryLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExpenseTrackerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:expense_tracker, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExpenseTrackerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
