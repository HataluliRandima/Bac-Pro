defmodule BacPro.Workershook.ErrorHook do
  require Logger

  def after_process(state, job, _result) when state in [:discard, :error, :cancel] do
    error = job.unsaved_error
    extra = Map.take(job, [:attempt, :id, :args, :max_attempts, :meta, :queue, :worker])
    tags = %{oban_worker: job.worker, oban_queue: job.queue, oban_state: job.state}

   IO.inspect(job)
   IO.inspect(state)
   IO.inspect(error.stacktrace)
   Logger.error(error.reason)
   IO.inspect(error.reason, stacktrace: error.stacktrace, tags: tags, extra: extra)
  end

  def after_process(_state, _job, _result), do: :ok
end
