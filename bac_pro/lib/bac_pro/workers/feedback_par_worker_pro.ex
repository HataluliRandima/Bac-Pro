defmodule BacPro.Workers.FeedbackParWorkerPro do

  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer

  import Ecto.Query, warn: false
  alias BacPro.Repo

  # import Bamboo.Email

  use Oban.Pro.Workers.Workflow, queue: :events, max_attempts: 5, tags: ["feedback", "account"]

  @impl true
  def process(%Oban.Job{args: %{"account_id" => account_id, "amount_dep" => amount_dep, "amount_with" => amount_with}} = job) do
   Logger.info(" JUst feedback on parallel req_ammount#{amount_with} #{amount_dep} for this account #{account_id}")

    :ok
  end

  # Get email associated with the current account

end
