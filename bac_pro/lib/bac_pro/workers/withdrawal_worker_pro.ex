defmodule BacPro.Workers.WithdrawalWorkerPro do

  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer
  alias BacPro.Accounts
  alias BacPro.Accounts.Account
  alias BacPro.Accounts.Card

  import Ecto.Query, warn: false
  alias BacPro.Repo

  use Oban.Pro.Workers.Workflow, recorded: true,queue: :crato, max_attempts: 5, tags: ["account", "withdrwal"]

  @impl true
  def process(%Oban.Job{args: %{"account_id" => account_id, "witdraw_amount" => withdraw_amount}} = job) do

    with {:ok, new_balance} <- withdraw_from_account(account_id,withdraw_amount) do

      # even send email here
      IO.puts("ZWOITEAA")
      #but get customer id for this account
      {:ok, new_balance}
    else
      {:error, reason} ->
        # %{"to" =>  email_stru, "subject" => "Account  registation failed", "body" => "You verification failedyour account #{email_stru} and #{reason} !!!"}
        # |> BAC.Workers.Emailjob.new()
        # |> Oban.insert()
        {:error, IO.inspect(reason)}

  end

end

  def withdraw_from_account(account_id, withdrawal_amount) do
    case get_balance(account_id) do
      {:ok, balance} ->
        if withdrawal_amount > balance do
          {:error, "Insufficient funds"}
        else
          new_balance = balance - withdrawal_amount
          case update_balance(account_id, new_balance) do
            :ok ->
              {:ok, new_balance}
            {:error, reason} ->
              {:error, "Failed to update balance: #{reason}"}
          end
        end
      {:error, reason} ->
        {:error, "Failed to get balance: #{reason}"}
    end
  end

  defp get_account_v2(id), do: Repo.get(Account, id)

  def get_account_struct_v2(id) do
    case get_account_v2(id) do
      nil -> {:error, "This account doesnt exist in our system."}
      account -> {:ok, account}
    end
  end

  def get_balance(account_id) do
    with {:ok,%Account{} = account} <- get_account_struct_v2(account_id) do
    # {:ok, balance} <- balance_db(account)

      {:ok, account.balance}
      # {:ok, balance}
    else
      {:error, reason} ->
        {:error, IO.inspect(reason)}
    end
  end

  def update_balance(account_id, new_balance) do
    {1, [updated_account]} =
      from(mm in Account, where: mm.id == ^account_id, select: mm)
      |> BacPro.Repo.update_all(set: [balance: new_balance])

    :ok
  end
  # def balance_db(account) do
  #   Accpu


end
