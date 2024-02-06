defmodule BacPro.Workers.CreateAccountWorkerPro do


  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer
  alias BacPro.Accounts
  alias BacPro.Accounts.Account
  alias BacPro.Accounts.Card

  import Ecto.Query, warn: false
  alias BacPro.Repo


  import Bamboo.Email

  use Oban.Pro.Workers.Workflow, recorded: true,queue: :crato, max_attempts: 5, tags: ["account", "bank"]

  @impl true
  def process(%Oban.Job{args: %{"account" => account_params}} = job) do

    # Fetch recorded previous customer within the workflow
    {:ok, [customer_job]} =
      Repo.transaction(fn ->
        job
        |> stream_workflow_jobs()
        |> Stream.filter(&(&1.meta["name"] == "b"))
        |> Enum.to_list()
      end)

    {:ok, customer} = fetch_recorded(customer_job)
    IO.puts "Randima"
    IO.inspect(customer)

  #  with {:ok, %Customer{} = customer_struct} <- get_customer_struct_v2(customer_id),
  with {:ok, %Account{} = account} <- Accounts.create_account(customer, account_params) do

      # %{"to" =>  customer_struct.email, "subject" => "Account Registration", "body" => "You have suscceful registered your account #{customer_struct.email}  this is your id you will use #{customer_struct.id}!!!"}
      # |> BAC.Workers.Emailjob.new()
      # |> Oban.insert()


     Logger.info("Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Worker: #{job.worker}|Job attempt: #{job.attempt}")

     {:ok, account}

    else
      {:error, reason} ->
        # %{"to" =>  email_stru, "subject" => "Account  registation failed", "body" => "You verification failedyour account #{email_stru} and #{reason} !!!"}
        # |> BAC.Workers.Emailjob.new()
        # |> Oban.insert()
        {:error, IO.inspect(reason)}
    end

  end

  defp get_customer_v2(id), do: Repo.get(Customer, id)

  def get_customer_struct_v2(id) do
    case get_customer_v2(id) do
      nil -> {:error, "This customer doesnt exist in our system."}
      customer -> {:ok, customer}
    end
  end


end
