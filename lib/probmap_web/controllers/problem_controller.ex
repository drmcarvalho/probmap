defmodule ProbMapWeb.ProblemController do
  use ProbMapWeb, :controller

  def index(conn, _params) do
    json(conn, %{method: "GET", action: "/api/problem"})
  end

  def criteria(conn, _params) do
    json(conn, %{method: "GET", action: "/api/problem/criteria"})
  end

  def create(conn, params) do
    description = params["description"]
    type = params["type"]

    cond do
      ProbMap.CoreLogic.blank?(description) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "description is required"})

      ProbMap.CoreLogic.blank?(type) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "type is required"})

      true ->
        case ProbMap.Problems.create_problem(%{"description" => description, "type" => type}) do
          {:ok, problem} ->
            conn
            |> put_status(:created)
            |> json(%{
              id: problem.id,
              description: problem.description,
              type: problem.type,
              inserted_at: problem.inserted_at,
              updated_at: problem.updated_at
            })

          {:error, changeset} ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "invalid data", details: format_changeset_errors(changeset)})
        end
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def update(conn, _params) do
    json(conn, %{method: "PUT", action: "/api/problem"})
  end

  def delete(conn, _params) do
    json(conn, %{method: "DELETE", action: "/api/problem"})
  end
end
