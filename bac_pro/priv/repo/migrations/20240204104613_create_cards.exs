defmodule BacPro.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards,primary_key: false) do
      add :id, :uuid, primary_key: true
      add :card_number, :string
      add :expiry_date, :string
      add :cvv, :string
      add :card_status, :string, default: "NotActivated", null: false
      add :account_id, references(:accounts, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:cards, [:account_id, :card_number])
  end
end
