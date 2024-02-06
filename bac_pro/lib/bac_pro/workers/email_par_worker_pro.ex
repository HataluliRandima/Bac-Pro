defmodule BacPro.Workers.EmailParWorkerPro do
  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer

  import Ecto.Query, warn: false
  alias BacPro.Repo

  # import Bamboo.Email

  use Oban.Pro.Workers.Workflow, queue: :events, max_attempts: 5, tags: ["feedback", "account"]

  @impl true
  def process(%Oban.Job{} = job) do
   Logger.info(" All above workers have completed their job")

    :ok
  end
end
