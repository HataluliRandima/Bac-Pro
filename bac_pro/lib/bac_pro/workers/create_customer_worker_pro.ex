defmodule BacPro.Workers.CreateCustomerWorkerPro do
  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer

  import Ecto.Query, warn: false
  alias BacPro.Repo

  import Bamboo.Email

  use Oban.Pro.Workers.Workflow, recorded: true, queue: :events, max_attempts: 3, tags: ["customer", "email"]

  @impl true
  def process(%Oban.Job{args: %{"customer" => customer_params}} = job) do

    email_stru = Map.get(customer_params, "email")
    id_stru = Map.get(customer_params, "idNumber")


   # with {:ok, %Oban.Job{} = job} <-  Oban.insert(BAC.Workers.CustomerValidatorWorker.new(%{"customer" => customer_params})),
    with {:ok, message} <- check_email(email_stru),
    {:ok, %Customer{} = customer} <- Customers.create_customer(customer_params) do

      # %{"to" =>  customer.email, "subject" => "Account Registration", "body" => "You have suscceful registered your account #{customer.email}  this is your id you will use #{customer.id}!!!"}
      # |> BAC.Workers.Emailjob.new()
      # |> Oban.insert()

    # Oban.Notifier.notify(Oban, :bac_jobs, %{complete: job.id})

     Logger.info("Customer creation Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Worker: #{job.worker}|Job attempt: #{job.attempt}")

     {:ok, customer}

    else
      {:error, reason} ->
        # %{"to" =>  email_stru, "subject" => "Account  registation failed", "body" => "You verification failedyour account #{email_stru} and #{reason} !!!"}
        # |> BAC.Workers.Emailjob.new()
        # |> Oban.insert()

        Logger.error("Customer creation Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Job queue: #{job.attempt} | Error : #{reason}")
        {:error, reason}
    end


  end

  @impl Oban.Pro.Worker
  def after_process(state, %Job{} = job, customer) do
    IO.puts("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
     IO.inspect(customer)
     IO.puts("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB")
     Logger.info("oban-jobs with hooks, #{state}, id: #{job.id} and}")
  end


  def check_email(email) do
    case BacPro.Repo.get_by(BacPro.Customers.Customer, email: email) do
      nil ->
        # Email doesn't exist, you can proceed with your logic here
        {:ok, "Email does not exist."}

      _user ->
        # Email already exists in the database, raise an error or handle accordingly
        {:error, "Email already exists."}
    end
  end

end
