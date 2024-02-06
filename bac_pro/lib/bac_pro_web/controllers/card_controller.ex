defmodule BacProWeb.CardController do
  use BacProWeb, :controller

  alias BacPro.Accounts
  alias BacPro.Accounts.Card

  action_fallback BacProWeb.FallbackController

  def index(conn, _params) do
    cards = Accounts.list_cards()
    render(conn, :index, cards: cards)
  end

  def create(conn, %{"card" => card_params}) do
    with {:ok, %Card{} = card} <- Accounts.create_card(card_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/cards/#{card}")
      |> render(:show, card: card)
    end
  end

  def show(conn, %{"id" => id}) do
    card = Accounts.get_card!(id)
    render(conn, :show, card: card)
  end

  def update(conn, %{"id" => id, "card" => card_params}) do
    card = Accounts.get_card!(id)

    with {:ok, %Card{} = card} <- Accounts.update_card(card, card_params) do
      render(conn, :show, card: card)
    end
  end

  def delete(conn, %{"id" => id}) do
    card = Accounts.get_card!(id)

    with {:ok, %Card{}} <- Accounts.delete_card(card) do
      send_resp(conn, :no_content, "")
    end
  end
end
