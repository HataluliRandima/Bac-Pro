defmodule BacPro.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts,primary_key: false) do
      add :id, :uuid, primary_key: true
      add :account_type, :string, default: "Savings", null: false
      add :account_number, :string
      add :account_status, :string, default: "NotVerified", null: false
      add :balance, :float
      add :open_date, :date, default: fragment("CURRENT_DATE")
      add :customer_id, references(:customers, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:accounts, [:customer_id, :account_number])
  end
end
