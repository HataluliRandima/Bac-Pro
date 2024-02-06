defmodule BacPro.Workers.ValidCardWorkerPro do

  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer

  alias BacPro.Accounts
  alias BacPro.Accounts.Card
  alias BacPro.Customers.Customer
  alias BacPro.Accounts.Account

  import Bamboo.Email

  import Ecto.Query, warn: false
  alias BacPro.Repo

  use Oban.Pro.Workers.Workflow, recorded: true, queue: :valid, priority: 3, max_attempts: 3, tags: ["account", "validation"]

  @impl true
  def process(%Oban.Job{args: %{"account_id" => account_id, "amount_dep" => amount_dep, "amount_with" => amount_with}} = job) do

    # check if account exist

    # To withdraw the ammount check in db

    with {:ok, _message1} <- get_account_struct_v2(account_id),
         {:ok, _,_} <- check_amounts(amount_dep,amount_with) do

     Logger.info("Customer validator Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Job queue: #{job.attempt}")
      :ok

    else
      {:error, reason} ->

        Logger.error("Customer validator Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Job queue: #{job.attempt} | Error : #{reason}")
        {:error, reason}
    end

  end


  defp get_account_v2(id), do: Repo.get(Account, id)

  def get_account_struct_v2(id) do
    case get_account_v2(id) do
      nil -> {:error, "This account doesnt exist in our system."}
      account -> {:ok, account}
    end
  end

  def check_amounts( deposit_amount, withdrawal_amount) when is_number(deposit_amount) and is_number(withdrawal_amount) do
    if deposit_amount > 0 and withdrawal_amount > 0 do
      {:ok, deposit_amount, withdrawal_amount}
    else
      {:error, "Both deposit and withdrawal amounts must be greater than 0"}
    end
  end
end
