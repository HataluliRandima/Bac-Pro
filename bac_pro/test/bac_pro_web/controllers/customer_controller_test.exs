defmodule BacProWeb.CustomerControllerTest do
  use BacProWeb.ConnCase

  import BacPro.CustomersFixtures

  alias BacPro.Customers.Customer

  @create_attrs %{
    status: "some status",
    firstname: "some firstname",
    lastname: "some lastname",
    email: "some email",
    phoneNumber: "some phoneNumber",
    dateOfBirth: "some dateOfBirth",
    idNumber: "some idNumber"
  }
  @update_attrs %{
    status: "some updated status",
    firstname: "some updated firstname",
    lastname: "some updated lastname",
    email: "some updated email",
    phoneNumber: "some updated phoneNumber",
    dateOfBirth: "some updated dateOfBirth",
    idNumber: "some updated idNumber"
  }
  @invalid_attrs %{status: nil, firstname: nil, lastname: nil, email: nil, phoneNumber: nil, dateOfBirth: nil, idNumber: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all customers", %{conn: conn} do
      conn = get(conn, ~p"/api/customers")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create customer" do
    test "renders customer when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/customers", customer: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/customers/#{id}")

      assert %{
               "id" => ^id,
               "dateOfBirth" => "some dateOfBirth",
               "email" => "some email",
               "firstname" => "some firstname",
               "idNumber" => "some idNumber",
               "lastname" => "some lastname",
               "phoneNumber" => "some phoneNumber",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/customers", customer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update customer" do
    setup [:create_customer]

    test "renders customer when data is valid", %{conn: conn, customer: %Customer{id: id} = customer} do
      conn = put(conn, ~p"/api/customers/#{customer}", customer: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/customers/#{id}")

      assert %{
               "id" => ^id,
               "dateOfBirth" => "some updated dateOfBirth",
               "email" => "some updated email",
               "firstname" => "some updated firstname",
               "idNumber" => "some updated idNumber",
               "lastname" => "some updated lastname",
               "phoneNumber" => "some updated phoneNumber",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, customer: customer} do
      conn = put(conn, ~p"/api/customers/#{customer}", customer: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete customer" do
    setup [:create_customer]

    test "deletes chosen customer", %{conn: conn, customer: customer} do
      conn = delete(conn, ~p"/api/customers/#{customer}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/customers/#{customer}")
      end
    end
  end

  defp create_customer(_) do
    customer = customer_fixture()
    %{customer: customer}
  end
end
