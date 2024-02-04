defmodule BacPro.Repo do
  use Ecto.Repo,
    otp_app: :bac_pro,
    adapter: Ecto.Adapters.Postgres
end
