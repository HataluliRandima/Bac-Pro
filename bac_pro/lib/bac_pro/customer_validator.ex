defmodule BacPro.CustomerValidator do
  import Ecto.Query, warn: false
  alias BacPro.Repo

  require Logger

  @email_regex ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

  def verify_id_number(idnumber) do
    case String.length(idnumber) do
      13 ->
        {:ok, "Valid email"}

      _ ->
        {:error, "ID number must be exactly 13 characters long"}
    end
  end

  def extract_dob(id) do
    dob_part = String.slice(id, 0..5)

    case Integer.parse(dob_part) do
      {dob, _rest} when dob > 0 ->
        year = div(dob, 10000)
        remaining = rem(dob, 10000)
        {month, day} = {div(remaining, 100), rem(remaining, 100)}

        formatted_date =
          String.pad_leading(Integer.to_string(year), 2, "0") <>
            "-" <>
            String.pad_leading(Integer.to_string(month), 2, "0") <>
            "-" <> String.pad_leading(Integer.to_string(day), 2, "0")

        formatted_date

      _ ->
        {:error, "Invalid date of birth"}
    end
  end

  def verify_email(email) do
    case Regex.match?(@email_regex, email) do
      true ->
        {:ok, email}

      false ->
        {:error, "Invalid email format"}
    end
  end

  def verify(phone_number) do
    case String.length(phone_number) do
      10 ->
        case String.starts_with?(phone_number, "0") do
          true -> {:ok, "Correct number"}
          false -> {:error, "Phone number must start with '0'"}
        end

      _ ->
        {:error, "Phone number must be 10 digits"}
    end
  end

  def verify(_), do: {:error, "Invalid phone number"}

  defp get_customer_v2(id), do: Repo.get(Customer, id)

  def get_customer_struct_v2(id) do
    case get_customer_v2(id) do
      nil -> {:error, "This customer doesnt exist in our system."}
      customer -> {:ok, customer}
    end
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

  # def all_validations() do

  # end

  def procheck do
    customer_params = %{
      email: "hata1111@gmail.com",
      dateOfBirth: "2000-10-22",
      idNumber: "5811111121211",
      firstname: "Hataluli",
      lastname: "Randima",
      phoneNumber: "727941660"
    }

    email = customer_params.email

    email_stru = Map.get(customer_params, "email")

    new_key = "account_number"
    new_value = BacPro.Run.generate_account_number()



   # expiration_date = BAC.Run.generate_expiration_date()
    # card_no = generate_card_number_v2()


    #customer_struct = IO.inspect(get_customer_user(customer_id))



    account_params = %{
      account_number: new_value,
      balance: 1500
    }
    # IO.inspect(email_stru)
    # IO.puts "Hello"

    #   with {:ok, message}<- check_email(email) do

    #     BAC.Workers.CustomerValidatorWorkerPro.new_workflow()
    #   |> BAC.Workers.CustomerValidatorWorkerPro.add(:a, BAC.Workers.CustomerValidatorWorkerPro.new(%{"customer" => customer_params}))
    #   |> BAC.Workers.CustomerValidatorWorkerPro.add(:b, BAC.Workers.CreateCustomerV2WorkerPro.new(%{"customer" => customer_params}), deps: [:a])
    #   |> BAC.Workers.CustomerValidatorWorkerPro.add(:c, BAC.Workers.EmailjobPro1.new(%{"customer" => customer_params}), deps: [:b])
    #   |> Oban.insert_all()
    #   |> IO.inspect()

    # else
    #   {:error, reason} ->
    #     {:error, IO.inspect(reason)}
    # end

    BacPro.Workers.CustomerValidatorWorkerPro.new_workflow()
    |> BacPro.Workers.CreateCustomerWorkerPro.add(
      :a,
      BacPro.Workers.CustomerValidatorWorkerPro.new(%{"customer" => customer_params})
    )
    |> BacPro.Workers.CustomerValidatorWorkerPro.add(
      :b,
      BacPro.Workers.CreateCustomerWorkerPro.new(%{"customer" => customer_params}),
      deps: [:a]
    )
    |> BacPro.Workers.CreateAccountWorkerPro.add(
      :c,
      BacPro.Workers.CreateAccountWorkerPro.new(%{"account" => account_params}),
      deps: [:b]
    )
    |> BacPro.Workers.CreateCardWorkerPro.add(
      :d,
      BacPro.Workers.CreateCardWorkerPro.new(%{}),
      deps: [:c]
    )
    |> BacPro.Workers.EmailWorkerPro.add(
      :e,
      BacPro.Workers.EmailWorkerPro.new(%{"customer" => customer_params}),
      deps: [:d]
    )
    |> Oban.insert_all()

  end

  # Parallel functions

  def par_fun do

    account_id = "060a632d-b977-4190-9b9d-0fc8dd47e7de"
    amount_dep = 120
    amount_with = 200
    withdraw_amount = 200
    deposit_amount = 120

    BacPro.Workers.ValidCardWorkerPro.new_workflow()
    |> BacPro.Workers.ValidCardWorkerPro.add(
      :aa,
      BacPro.Workers.ValidCardWorkerPro.new(%{"account_id" => account_id, "amount_dep" => amount_dep, "amount_with" => amount_with})
    )
    |> BacPro.Workers.ValidCardWorkerPro.add(
      :bb,
      BacPro.Workers.WithdrawalWorkerPro.new(%{"account_id" => account_id, "witdraw_amount" => withdraw_amount}),
      deps: [:aa]
    )
    |> BacPro.Workers.DepositWorkerPro.add(
      :cc,
      BacPro.Workers.DepositWorkerPro.new(%{"account_id" => account_id, "deposit_amount" => deposit_amount}),
      deps: [:aa]
    )
    |> BacPro.Workers.FeedbackParWorkerPro.add(
      :dd,
      BacPro.Workers.FeedbackParWorkerPro.new(%{"account_id" => account_id, "amount_dep" => amount_dep, "amount_with" => amount_with}),
      deps: [:aa]
    )
    |> BacPro.Workers.EmailParWorkerPro.add(
      :ee,
      BacPro.Workers.EmailParWorkerPro.new(%{}),
      deps: [:aa, :bb, :cc, :dd]
    )
    |> Oban.insert_all()


  end


  def milo(num) do
    customer_params = %{
      email: "hata@gmail.com",
      dateOfBirth: "2000-10-22",
      idNumber: "5811111121211",
      firstName: "Hataluli",
      lastName: "Randima",
      phoneNumber: "0727941660"
    }

    # {:ok, _jobs} = BAC.Workers.WorkflowWorkerPro.process(%{"customer" => customer_params})

    #  BacPro.Workers.WorkflowWorkerPro.new(%{"num" => num})
    #   |> Oban.insert()
  end
end
