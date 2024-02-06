defmodule BacPro.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BacPro.Customers` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        dateOfBirth: "some dateOfBirth",
        email: "some email",
        firstname: "some firstname",
        idNumber: "some idNumber",
        lastname: "some lastname",
        phoneNumber: "some phoneNumber",
        status: "some status"
      })
      |> BacPro.Customers.create_customer()

    customer
  end
end
