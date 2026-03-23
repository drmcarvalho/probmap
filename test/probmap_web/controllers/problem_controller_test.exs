defmodule ProbMapWeb.ProblemControllerTest do
  use ProbMapWeb.ConnCase, async: true

  describe "GET /api/problem/criteria" do
    test "returns mock JSON with GET method and criteria action", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/criteria")
      assert json_response(conn, 200) == %{"method" => "GET", "action" => "/api/problem/criteria"}
    end
  end

  describe "GET /api/problem" do
    test "returns mock JSON with GET method", %{conn: conn} do
      conn = get(conn, ~p"/api/problem")
      assert json_response(conn, 200) == %{"method" => "GET", "action" => "/api/problem"}
    end
  end

  describe "POST /api/problem" do
    test "returns mock JSON with POST method", %{conn: conn} do
      conn = post(conn, ~p"/api/problem")
      assert json_response(conn, 200) == %{"method" => "POST", "action" => "/api/problem"}
    end
  end

  describe "PUT /api/problem" do
    test "returns mock JSON with PUT method", %{conn: conn} do
      conn = put(conn, ~p"/api/problem")
      assert json_response(conn, 200) == %{"method" => "PUT", "action" => "/api/problem"}
    end
  end

  describe "DELETE /api/problem" do
    test "returns mock JSON with DELETE method", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem")
      assert json_response(conn, 200) == %{"method" => "DELETE", "action" => "/api/problem"}
    end
  end
end
