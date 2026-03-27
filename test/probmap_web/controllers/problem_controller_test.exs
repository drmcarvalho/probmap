defmodule ProbMapWeb.ProblemControllerTest do
  use ProbMapWeb.ConnCase, async: true

  describe "GET /api/problem/criteria" do
    test "returns empty list when no problems exist", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/criteria")
      assert json_response(conn, 200) == []
    end

    test "returns all problems when no q param", %{conn: conn} do
      {:ok, _} = ProbMap.ProblemsContext.create_problem(%{"description" => "First", "type" => "algorithmic"})
      {:ok, _} = ProbMap.ProblemsContext.create_problem(%{"description" => "Second", "type" => "undecidable"})

      conn = get(conn, ~p"/api/problem/criteria")
      result = json_response(conn, 200)

      assert length(result) == 2
      assert Enum.all?(result, fn p ->
        Map.has_key?(p, "problemId") and
        Map.has_key?(p, "description") and
        Map.has_key?(p, "type") and
        Map.has_key?(p, "inserted_at") and
        Map.has_key?(p, "updated_at")
      end)
    end

    test "filters problems by q param", %{conn: conn} do
      {:ok, _} = ProbMap.ProblemsContext.create_problem(%{"description" => "alpha test", "type" => "algorithmic"})
      {:ok, _} = ProbMap.ProblemsContext.create_problem(%{"description" => "beta example", "type" => "algorithmic"})

      conn = get(conn, ~p"/api/problem/criteria?q=alpha")
      result = json_response(conn, 200)

      assert length(result) == 1
      assert hd(result)["description"] == "alpha test"
    end

    test "returns empty list when q matches nothing", %{conn: conn} do
      {:ok, _} = ProbMap.ProblemsContext.create_problem(%{"description" => "something", "type" => "algorithmic"})

      conn = get(conn, ~p"/api/problem/criteria?q=nonexistent")
      assert json_response(conn, 200) == []
    end
  end

  describe "GET /api/problem/:id" do
    test "returns problem when it exists", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "Test", "type" => "algorithmic"})

      conn = get(conn, ~p"/api/problem/#{problem.id}")
      result = json_response(conn, 200)

      assert result["problemId"] == problem.id
      assert result["description"] == "Test"
      assert result["type"] == "algorithmic"
    end

    test "returns 404 when problem does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/999999")
      assert json_response(conn, 404) == %{"error" => "Problem not found"}
    end

    test "returns 400 when id is not a positive integer", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/abc")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is zero", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/0")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is negative", %{conn: conn} do
      conn = get(conn, ~p"/api/problem/-5")
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end

  describe "POST /api/problem" do
    test "creates problem successfully", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"description" => "Test problem", "type" => "algorithmic"})
      result = json_response(conn, 201)

      assert result["id"]
      assert result["description"] == "Test problem"
      assert result["type"] == "algorithmic"
      assert result["inserted_at"]
      assert result["updated_at"]
    end

    test "returns 400 when description is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "description is required"}
    end

    test "returns 400 when description is blank", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"description" => "  ", "type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "description is required"}
    end

    test "returns 400 when type is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"description" => "A problem"})
      assert json_response(conn, 400) == %{"error" => "type is required"}
    end

    test "returns 400 when type is blank", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"description" => "A problem", "type" => ""})
      assert json_response(conn, 400) == %{"error" => "type is required"}
    end

    test "returns 400 when unknown parameter is present", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"description" => "A", "type" => "algorithmic", "foo" => "bar"})
      assert json_response(conn, 400) == %{"error" => "unknown parameter: foo"}
    end

    test "creates problem with inputs successfully", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{
        "description" => "With inputs",
        "type" => "algorithmic",
        "inputs" => [%{"data" => "d1"}, %{"data" => "d2"}]
      })
      result = json_response(conn, 201)

      assert result["id"]
      assert result["description"] == "With inputs"
    end

    test "returns 400 when inputs contain blank data", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{
        "description" => "X",
        "type" => "algorithmic",
        "inputs" => [%{"data" => "ok"}, %{"data" => ""}]
      })
      assert json_response(conn, 400) == %{"error" => "input data is required at index 1"}
    end

    test "returns 400 for invalid type value", %{conn: conn} do
      conn = post(conn, ~p"/api/problem", %{"description" => "Test", "type" => "invalid_type"})
      result = json_response(conn, 400)

      assert result["error"] == "invalid data"
    end
  end

  describe "PUT /api/problem/:id" do
    test "updates problem successfully", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "old", "type" => "algorithmic"})

      conn = put(conn, ~p"/api/problem/#{problem.id}", %{"description" => "new", "type" => "np_complete"})
      assert response(conn, 204)
    end

    test "returns 400 when description is missing", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "x", "type" => "algorithmic"})

      conn = put(conn, ~p"/api/problem/#{problem.id}", %{"type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "description is required"}
    end

    test "returns 400 when description is blank", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "x", "type" => "algorithmic"})

      conn = put(conn, ~p"/api/problem/#{problem.id}", %{"description" => "", "type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "description is required"}
    end

    test "returns 400 when type is missing", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "x", "type" => "algorithmic"})

      conn = put(conn, ~p"/api/problem/#{problem.id}", %{"description" => "valid"})
      assert json_response(conn, 400) == %{"error" => "type is required"}
    end

    test "returns 400 when type is blank", %{conn: conn} do
      {:ok, problem} = ProbMap.ProblemsContext.create_problem(%{"description" => "x", "type" => "algorithmic"})

      conn = put(conn, ~p"/api/problem/#{problem.id}", %{"description" => "valid", "type" => ""})
      assert json_response(conn, 400) == %{"error" => "type is required"}
    end

    test "returns 404 when problem does not exist", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/999999", %{"description" => "x", "type" => "algorithmic"})
      assert json_response(conn, 404) == %{"error" => "Problem not found"}
    end

    test "returns 400 when id is not a positive integer", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/abc", %{"description" => "x", "type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is negative", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/-1", %{"description" => "x", "type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end

    test "returns 400 when id is zero", %{conn: conn} do
      conn = put(conn, ~p"/api/problem/0", %{"description" => "x", "type" => "algorithmic"})
      assert json_response(conn, 400) == %{"error" => "id must be a positive integer"}
    end
  end

  describe "GET /api/types" do
    test "returns all 5 type classifications", %{conn: conn} do
      conn = get(conn, ~p"/api/types")
      result = json_response(conn, 200)

      assert length(result) == 5
      assert Enum.at(result, 0) == %{"type_description" => "No solution \u2014 undecidable", "types" => ["undecidable"]}
      assert Enum.at(result, 1) == %{"type_description" => "Formal step-by-step solution", "types" => ["algorithmic"]}
      assert Enum.at(result, 2) == %{"type_description" => "NP-Complete complexity", "types" => ["intermediate", "np_complete"]}
      assert Enum.at(result, 3) == %{"type_description" => "Solvable by humans", "types" => ["intermediate", "human_solvable"]}
      assert Enum.at(result, 4) == %{"type_description" => "Solvable by living beings", "types" => ["intermediate", "biosolvable"]}
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
