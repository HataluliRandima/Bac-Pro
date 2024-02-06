defmodule BacProWeb.Router do
  use BacProWeb, :router

  import Oban.Web.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BacProWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BacProWeb do
    pipe_through :api

    get "/", PageController, :home

    resources "/cards", CardController, except: [:new, :edit]
    resources "/service_activation_logs", ServiceActivationLogController, except: [:new, :edit]
    resources "/accounts", AccountController, except: [:new, :edit]
    resources "/customers", CustomerController, except: [:new, :edit]

  end

  scope "/hata", BacProWeb do
    pipe_through :browser


    oban_dashboard "/oban"

  end

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    # If using Plug.Router, make sure to add the `to`
    # forward "/sent_emails", to: Bamboo.SentEmailViewerPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", BacProWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bac_pro, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser



      live_dashboard "/dashboard", metrics: BacProWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
