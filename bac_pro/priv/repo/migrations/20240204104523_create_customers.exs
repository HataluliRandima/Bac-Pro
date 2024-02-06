defmodule BacPro.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers,primary_key: false) do
      add :id, :uuid, primary_key: true
      add :firstname, :string
      add :lastname, :string
      add :email, :string
      add :phoneNumber, :string
      add :dateOfBirth, :string
      add :idNumber, :string
      add :status, :string, default: "InActive", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:customers, [:email])
  end
end
