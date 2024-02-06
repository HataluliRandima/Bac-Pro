defmodule BacPro.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :balance, :float
    field :account_type, :string
    field :account_number, :string
    field :account_status, :string
    field :open_date, :date
    #field :customer_id, :id

    belongs_to :customer, BacPro.Customers.Customer
    has_many :card, BacPro.Accounts.Card

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:account_type, :account_number, :account_status, :balance, :open_date,:customer_id])
    |> validate_required([:customer_id])
  end
end
