defmodule BacPro.Workers.EmailWorkerPro do
  require Logger
  alias BacPro.ObMailer

  import Bamboo.Email

  import Ecto.Query, warn: false
  alias BacPro.Repo

  use Oban.Pro.Workers.Workflow, queue: :events, max_attempts: 3, tags: ["customer", "email"], unique: [period: 60]
  # def process(%Oban.Job{state: state,attempt: attempt,args: %{"to" => to, "subject" => subject, "body" => body}} = job) do
  @impl true
  def process(%Oban.Job{state: state,attempt: attempt,args: %{"customer" => customer_params}} = job) do

    {:ok, [token_job]} =
      Repo.transaction(fn ->
        job
        |> stream_workflow_jobs()
        |> Stream.filter(&(&1.meta["name"] == "b"))
        |> Enum.to_list()
      end)

    {:ok, customer} = fetch_recorded(token_job)
    IO.puts "Randima"
    IO.inspect(customer)


    email_stru = Map.get(customer_params, "email")
    IO.inspect(email_stru)

   # Logger.info("Job id: #{inspect(job.id)} | Job attempted at: #{inspect(job.attempted_at)}| Job state: #{inspect(job.state)} | Job queue: #{inspect(job.queue)} | #{to} | #{state} | #{attempt}")


    email = new_email(
          to: email_stru,
          from: "bacsupport@gmail.com",
          subject: "ACCOUNT REGISTERED",
          text_body: "Congradulations"
        )
        ObMailer.deliver_now(email)

    {:ok, email}
  end
end
