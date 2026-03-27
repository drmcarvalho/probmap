defmodule ProbMapWeb.DataOfProblemControllerTest do
  use ProbMapWeb.ConnCase, async: true

  setup %{} do
    {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "Test Problem", "type" => "algorithmic"})
    %{problem: problem}
  end

  defp create_data(problem, data \\ "test data") do
    {:ok, d} = ProbMap.ProblemsContext.create_data_of_problem(problem, %{"data" => data})
    d
  end

  describe "GET /api/problem/:id/data/criteria" do
    test "returns empty list when no data exists", %{conn: conn, problem: problem} do
      conn = get(conn, ~p"/api/problem/#{problem.id}/data/criteria")
      assert json_response(conn, 200) == []
    end

    test "returns all data when no q param", %{conn: conn, problem: problem} do
      create_data(problem, "data one")
      create_data(problem, "data two")

      conn = get(conn, ~p"/api/problem/#{problem.id}/data/criteria")
      result = json_response(conn, 200)

      assert length(result) == 2
      assert Enum.all?(result, fn d ->
        Map.has_key?(d, "data") and
        Map.has_key?(d, "dataId") and
        Map.has_key?(d, "problemId")
      end)
    end

    test "filters data by q param", %{conn: conn, problem: problem} do
      create_data(problem, "alpha info")
      create_data(problem, "beta info")

      conn = get(conn, "/api/problem/#{problem.id}/data/criteria?q=alpha")
      result = json_response(conn, 200)

      assert length(result) == 1
      assert hd(result)["data"] == "alpha info"
    end

    test "returns empty list when q matches nothing", %{conn: conn, problem: problem} do
      create_data(problem, "something")

      conn = get(conn, "/api/problem/#{problem.id}/data/criteria?q=nonexistent")
      assert json_response(conn, 200) == []
    end

    test "returns 400 when id is not a positive integer", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/abc/data/criteria")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is zero", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/0/data/criteria")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is negative", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/-1/data/criteria")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end

  describe "POST /api/problem/:id/data" do
    test "creates data successfully", %{conn: conn, problem: problem} do
      conn = post(conn, ~p"/api/problem/#{problem.id}/data", %{"data" => "new data"})
      assert response(conn, 201)
    end

    test "returns 400 when data is missing", %{conn: conn, problem: problem} do
      conn = post(conn, ~p"/api/problem/#{problem.id}/data", %{})
      assert json_response(conn, 400) == %{"error" => "data is required"}
    end

    test "returns 400 when data is blank", %{conn: conn, problem: problem} do
      conn = post(conn, ~p"/api/problem/#{problem.id}/data", %{"data" => "  "})
      assert json_response(conn, 400) == %{"error" => "data is required"}
    end

    test "returns 404 when unknown field is present", %{conn: conn, problem: problem} do
      conn = post(conn, ~p"/api/problem/#{problem.id}/data", %{"data" => "x", "extra" => "bad"})
      result = json_response(conn, 404)
      assert result["error"] =~ "unknown field"
    end

    test "returns 404 when problem does not exist", %{conn: conn} do
      conn = post(conn, ~p"/api/problem/999999/data", %{"data" => "x"})
      assert json_response(conn, 404) == %{"error" => "Problem not found"}
    end

    test "returns 400 when id is not a positive integer", %{conn: conn} do
      conn = post(conn, ~p"/api/problem/abc/data", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is zero", %{conn: conn} do
      conn = post(conn, ~p"/api/problem/0/data", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is negative", %{conn: conn} do
      conn = post(conn, ~p"/api/problem/-3/data", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end

  describe "PUT /api/problem/:id/data/:dataid" do
    test "updates data successfully", %{conn: conn, problem: problem} do
      data = create_data(problem)

      conn = put(conn, ~p"/api/problem/#{problem.id}/data/#{data.id}", %{"data" => "updated"})
      assert response(conn, 204)
    end

    test "returns 400 when data field is missing", %{conn: conn, problem: problem} do
      data = create_data(problem)

      conn = put(conn, ~p"/api/problem/#{problem.id}/data/#{data.id}", %{})
      assert json_response(conn, 400) == %{"error" => "data is required"}
    end

    test "returns 400 when data field is blank", %{conn: conn, problem: problem} do
      data = create_data(problem)

      conn = put(conn, ~p"/api/problem/#{problem.id}/data/#{data.id}", %{"data" => ""})
      assert json_response(conn, 400) == %{"error" => "data is required"}
    end

    test "returns 404 when unknown field is present", %{conn: conn, problem: problem} do
      data = create_data(problem)

      conn = put(conn, ~p"/api/problem/#{problem.id}/data/#{data.id}", %{"data" => "x", "extra" => "y"})
      result = json_response(conn, 404)
      assert result["error"] =~ "unknown field"
    end

    test "returns 404 when problem does not exist", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/999999/data/1", %{"data" => "x"})
      assert json_response(conn, 404) == %{"error" => "Problem not found"}
    end

    test "returns 404 when data_of_problem does not exist", %{conn: conn, problem: problem} do
      conn = put(conn, ~p"/api/problem/#{problem.id}/data/999999", %{"data" => "x"})
      assert json_response(conn, 404) == %{"error" => "Data of Problem not found"}
    end

    test "returns 400 when problem id is not a positive integer", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/abc/data/1", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when dataid is not a positive integer", %{conn: conn, problem: problem} do
      conn = put(conn, ~p"/api/problem/#{problem.id}/data/abc", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when problem id is zero", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/0/data/1", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when dataid is zero", %{conn: conn, problem: problem} do
      conn = put(conn, ~p"/api/problem/#{problem.id}/data/0", %{"data" => "x"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end

  describe "DELETE /api/problem/:id/data/:dataid" do
    test "deletes data successfully", %{conn: conn, problem: problem} do
      data = create_data(problem)

      conn = delete(conn, ~p"/api/problem/#{problem.id}/data/#{data.id}")
      assert response(conn, 204)
    end

    test "returns 404 when problem does not exist", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/999999/data/1")
      assert json_response(conn, 404) == %{"error" => "Problem not found"}
    end

    test "returns 404 when data_of_problem does not exist", %{conn: conn, problem: problem} do
      conn = delete(conn, ~p"/api/problem/#{problem.id}/data/999999")
      assert json_response(conn, 404) == %{"error" => "Data of Problem not found"}
    end

    test "returns 400 when problem id is not a positive integer", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/abc/data/1")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when dataid is not a positive integer", %{conn: conn, problem: problem} do
      conn = delete(conn, ~p"/api/problem/#{problem.id}/data/abc")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when problem id is negative", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/-1/data/1")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when dataid is negative", %{conn: conn, problem: problem} do
      conn = delete(conn, ~p"/api/problem/#{problem.id}/data/-1")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when both ids are zero", %{conn: conn} do
      conn = delete(conn, ~p"/api/problem/0/data/0")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end
end
