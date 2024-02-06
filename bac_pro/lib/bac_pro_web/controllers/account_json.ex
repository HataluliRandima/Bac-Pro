defmodule BacProWeb.AccountJSON do
  alias BacPro.Accounts.Account

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account.
  """
  def show(%{account: account}) do
    %{data: data(account)}
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      account_type: account.account_type,
      account_number: account.account_number,
      account_status: account.account_status,
      balance: account.balance,
      open_date: account.open_date
    }
  end
end
