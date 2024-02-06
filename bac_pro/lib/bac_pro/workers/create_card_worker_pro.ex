defmodule BacPro.Workers.CreateCardWorkerPro do
  require Logger
  # alias BacPro.ObMailer
  alias BacPro.Customers
  alias BacPro.Customers.Customer
  alias BacPro.Accounts
  alias BacPro.Accounts.Card
  alias BacPro.Customers.Customer
  alias BacPro.Accounts.Account

  import Ecto.Query, warn: false
  alias BacPro.Repo

  #import Bamboo.Email

  use Oban.Pro.Workers.Workflow, recorded: true,queue: :events, max_attempts: 3, tags: ["card", "bank"]

  @impl true
  def process(%Oban.Job{} = job) do

    IO.puts("start")

       # Fetch recorded previous customer within the workflow
       {:ok, [account_job]} =
        Repo.transaction(fn ->
          job
          |> stream_workflow_jobs()
          |> Stream.filter(&(&1.meta["name"] == "c"))
          |> Enum.to_list()
        end)

      {:ok, account} = fetch_recorded(account_job)
      IO.puts "Musanda"
      IO.inspect(account)



    with {:ok, card_str} <- get_card_no(),
    {:ok, new_cvv} <- gen_cvv(card_str),
    {:ok, new_exp} <- generate_expiration_date_now(),
    {:ok, params_card } <- gen_new_card_params(card_str,new_exp,new_cvv),
     {:ok, %Card{} = card} <- Accounts.create_card(account, params_card) do

    #   %{"to" =>  customer.email, "subject" => "Account Registration", "body" => "You have suscceful registered your account #{customer.email}  this is your id you will use #{customer.id}!!!"}
    #   |> BAC.Workers.Emailjob.new()
    #   |> Oban.insert()

    #  Oban.Notifier.notify(Oban, :bac_jobs, %{complete: job.id})
     IO.puts("Card activated")
     Logger.info("Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | Worker: #{job.worker}|Job attempt: #{job.attempt}")

     {:ok, card}

    else
      {:error, reason} ->
        # %{"to" =>  email_stru, "subject" => "Account  registation failed", "body" => "You verification failedyour account #{email_stru} and #{reason} !!!"}
        # |> BAC.Workers.Emailjob.new()
        # |> Oban.insert()
        {:error, IO.inspect(reason)}
    end
  end

  def get_card_no do
    #card_number = strc.card_number
    card_number = generate_card_number()

    {:ok , card_number}
  end

  defp get_customer_v2(id), do: Repo.get(Account, id)

  def get_customer_struct_v2(id) do
    case get_customer_v2(id) do
      nil -> {:error, "This account doesnt exist in our system."}
      account -> {:ok, account}
    end
  end

  def gen_cvv(card_no) do

    last_three_digits = String.slice(card_no, -3, 3)
    {:ok, last_three_digits}

  end

  def generate_expiration_date_now do
    current_year = Date.utc_today().year()
    random_month = Enum.random(1..12)
    random_year = current_year + Enum.random(1..5) # Generating a random year in the next 5 years

    month_string = String.pad_leading(Integer.to_string(random_month), 2, "0")
    year_string = Integer.to_string(random_year)

    # Extract the last two characters of the year string
    year_last_two_digits = String.slice(year_string, -2, 2)

    expiration_date = "#{month_string}/#{year_last_two_digits}"

    IO.puts("Generated Expiration Date: #{expiration_date}")

    {:ok,expiration_date}
  end

  def gen_new_card_params(card, exp, cvv) do
    card_params_new = %{"card_number" =>  card , "expiry_date" => exp , "cvv" => cvv }

    IO.puts("its lunch")
   {:ok, card_params_new }
  end

  defp generate_random_card_suffix do
    Integer.to_string(:rand.uniform(10_000_000_000_000))
    |> String.pad_leading(16, "0")
  end

  def generate_card_number do
    prefix = "6742"
    new_card_number = prefix <> generate_random_card_suffix()
   # new_account_number = generate_random_number()

    case BacPro.Repo.one(from(a in BacPro.Accounts.Card, where: a.card_number == ^new_card_number)) do
      nil ->

        # Account number doesn't exist, insert into the database
       # BAC.Repo.insert!(%YourApp.Accounts{account_number: new_account_number})
        new_card_number

      _existing_number ->
        # Account number already exists, generate a new one
        generate_card_number()
    end
  end



end
