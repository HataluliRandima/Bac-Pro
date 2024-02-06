defmodule BacPro.Accounts.Card do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cards" do
    field :card_number, :string
    field :expiry_date, :string
    field :cvv, :string
    field :card_status, :string
    #field :account_id, :id

    belongs_to :account, BacPro.Accounts.Account


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:card_number, :expiry_date, :cvv, :card_status])
    |> validate_required([:card_number, :expiry_date, :cvv])
  end
end
