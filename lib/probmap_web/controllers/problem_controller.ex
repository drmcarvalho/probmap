defmodule ProbMapWeb.ProblemController do
  use ProbMapWeb, :controller

  @spec criteria(Plug.Conn.t(), nil | maybe_improper_list() | map()) :: Plug.Conn.t()
  def criteria(conn, params) do
    search_term = params["q"]
    problems = ProbMap.Problems.search_problems(search_term)
    result =
      Enum.map(problems, fn problem -> %{
          problemId: problem.id,
          description: problem.description,
          type: Atom.to_string(problem.type),
          inserted_at: problem.inserted_at,
          updated_at: problem.updated_at
        }
      end)
    json(conn, result)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int_id, ""} when int_id > 0 ->
        case ProbMap.Problems.get_problem(int_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Problem not found"})
          problem ->
            conn
            |> json(%{
              problemId: problem.id,
              description: problem.description,
              type: to_string(problem.type)
            })
        end
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "id must be a positive integer"})
    end
  end

  @spec create(Plug.Conn.t(), nil | maybe_improper_list() | map()) :: Plug.Conn.t()
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

  @spec types(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def types(conn, _) do
    json(conn, [
      %{
        type_description: ProbMap.CoreLogic.classify(:undecidable),
        types:
          ProbMap.CoreLogic.to_classification(:undecidable)
          |> ProbMap.CoreLogic.classification_to_list()
      },
      %{
        type_description: ProbMap.CoreLogic.classify(:algorithmic),
        types:
          ProbMap.CoreLogic.to_classification(:algorithmic)
          |> ProbMap.CoreLogic.classification_to_list()
      },
      %{
        type_description: ProbMap.CoreLogic.classify(:np_complete),
        types:
          ProbMap.CoreLogic.to_classification(:np_complete)
          |> ProbMap.CoreLogic.classification_to_list()
      },
      %{
        type_description: ProbMap.CoreLogic.classify(:human_solvable),
        types:
          ProbMap.CoreLogic.to_classification(:human_solvable)
          |> ProbMap.CoreLogic.classification_to_list()
      },
      %{
        type_description: ProbMap.CoreLogic.classify(:biosolvable),
        types:
          ProbMap.CoreLogic.to_classification(:biosolvable)
          |> ProbMap.CoreLogic.classification_to_list()
      }
    ])
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @spec update(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def update(conn, _params) do
    json(conn, %{method: "PUT", action: "/api/problem"})
  end

  @spec delete(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def delete(conn, _params) do
    json(conn, %{method: "DELETE", action: "/api/problem"})
  end
end
