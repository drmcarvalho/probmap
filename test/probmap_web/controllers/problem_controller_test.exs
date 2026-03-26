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

  describe "DELETE /api/problem/:id" do
    test "returns 204 when problem exists", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "to delete", "type" => "algorithmic"})
      conn = delete(conn, ~p"/api/problem/#{problem.id}")
      assert response(conn, 204)
    end

    test "returns 404 when problem does not exist", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/999999")
      assert json_response(conn, 404) == %{"error" => "Problem not found"}
    end

    test "returns 400 when id is invalid", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/abc")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is negative", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/-1")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end
end
