defmodule BacPro.Repo.Migrations.AddPartitionedObanJobs do
  use Ecto.Migration

  defdelegate change, to: Oban.Pro.Migrations.DynamicPartitioner
end
