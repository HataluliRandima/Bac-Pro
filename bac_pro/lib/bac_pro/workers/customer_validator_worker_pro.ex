defmodule BacPro.Workers.CustomerValidatorWorkerPro do

  require Logger
  alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer

  import Bamboo.Email

  use Oban.Pro.Workers.Workflow, queue: :valid, priority: 3, max_attempts: 2, tags: ["customer", "validation"]

  @impl true
  def process(%Oban.Job{args: %{"customer" => customer_params}} = job) do

    email_stru = Map.get(customer_params, "email")
    IO.inspect(email_stru)
    id_stru = Map.get(customer_params, "idNumber")

    id = Map.get(customer_params, "idNumber")
    email = Map.get(customer_params, "email")
    phoneNumber = Map.get(customer_params, "phoneNumber")

    with {:ok, _message1} <- BacPro.CustomerValidator.verify_id_number(id),
         {:ok, cust_email} <- BacPro.CustomerValidator.verify_email(email),
         {:ok, _m} <- BacPro.CustomerValidator.verify(phoneNumber)  do
         #{:ok, job} <- Oban.insert(BAC.Workers.CreateCustomerV2Worker.new(%{"customer" => customer_params})) do


      # %{"to" =>  cust_email, "subject" => "Customer Verification", "body" => "You have suscceful verified your account #{cust_email} !!!"}
      # |> BAC.Workers.Emailjob.new()
      # |> Oban.insert()
     Logger.debug("Debugging", log: :debugging)
     Logger.info("Customer validator Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Job queue: #{job.attempt}")
      :ok

    else
      {:error, reason} ->
        # %{"to" =>  email, "subject" => "Account  verificationation", "body" => "You verification failedyour account #{email} and #{reason} !!!"}
        # |> BAC.Workers.Emailjob.new()
        # |> Oban.insert()
        Logger.info("HAHAHAHAHAHAHA")
        Logger.debug("BIg brother")
        Logger.debug("Debugging custmer", log: :debugging)
        Logger.error("Customer validator Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Job queue: #{job.attempt} | Error : #{reason}")
        {:error, reason}
    end

  end
end
