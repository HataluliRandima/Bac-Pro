defmodule BacPro.CustomersTest do
  use BacPro.DataCase

  alias BacPro.Customers

  describe "customers" do
    alias BacPro.Customers.Customer

    import BacPro.CustomersFixtures

    @invalid_attrs %{status: nil, firstname: nil, lastname: nil, email: nil, phoneNumber: nil, dateOfBirth: nil, idNumber: nil}

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{status: "some status", firstname: "some firstname", lastname: "some lastname", email: "some email", phoneNumber: "some phoneNumber", dateOfBirth: "some dateOfBirth", idNumber: "some idNumber"}

      assert {:ok, %Customer{} = customer} = Customers.create_customer(valid_attrs)
      assert customer.status == "some status"
      assert customer.firstname == "some firstname"
      assert customer.lastname == "some lastname"
      assert customer.email == "some email"
      assert customer.phoneNumber == "some phoneNumber"
      assert customer.dateOfBirth == "some dateOfBirth"
      assert customer.idNumber == "some idNumber"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      update_attrs = %{status: "some updated status", firstname: "some updated firstname", lastname: "some updated lastname", email: "some updated email", phoneNumber: "some updated phoneNumber", dateOfBirth: "some updated dateOfBirth", idNumber: "some updated idNumber"}

      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, update_attrs)
      assert customer.status == "some updated status"
      assert customer.firstname == "some updated firstname"
      assert customer.lastname == "some updated lastname"
      assert customer.email == "some updated email"
      assert customer.phoneNumber == "some updated phoneNumber"
      assert customer.dateOfBirth == "some updated dateOfBirth"
      assert customer.idNumber == "some updated idNumber"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
