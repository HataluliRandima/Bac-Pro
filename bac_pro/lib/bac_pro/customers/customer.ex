defmodule BacPro.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "customers" do
    field :status, :string
    field :firstname, :string
    field :lastname, :string
    field :email, :string
    field :phoneNumber, :string
    field :dateOfBirth, :string
    field :idNumber, :string

    has_many :account, BacPro.Accounts.Account
    has_many :service_activation_log, BacPro.Accounts.ServiceActivationLog

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:firstname, :lastname, :email, :phoneNumber, :dateOfBirth, :idNumber, :status])
    |> validate_required([:firstname, :lastname, :email, :phoneNumber, :dateOfBirth, :idNumber])
  end
end
