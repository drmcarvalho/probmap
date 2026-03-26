defmodule ProbMapWeb.ProblemController do
  use ProbMapWeb, :controller

  @spec criteria(Plug.Conn.t(), nil | maybe_improper_list() | map()) :: Plug.Conn.t()
  def criteria(conn, params) do
    search_term = params["q"]
    result = ProbMap.ProblemsContext.search_problems(search_term)
      |> Enum.map(fn problem -> %{
          problemId: problem.id,
          description: problem.description,
          type: Atom.to_string(problem.type),
          inserted_at: problem.inserted_at,
          updated_at: problem.updated_at
        }
      end)
    conn |> json(result)
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int_id, ""} when int_id > 0 ->
        case ProbMap.ProblemsContext.get_problem(int_id) do
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
    inputs = params["inputs"]
    unknown_keys = Map.keys(params) -- ["description", "type", "inputs"]
    cond do
      unknown_keys != [] ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "unknown parameter: #{Enum.join(unknown_keys, ", ")}"})
      ProbMap.CoreLogic.blank?(description) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "description is required"})
      ProbMap.CoreLogic.blank?(type) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "type is required"})
      true ->
        cond do
          is_list(inputs) and inputs != [] ->
            invalid_input =
              Enum.find_index(inputs, fn input ->
                ProbMap.CoreLogic.blank?(input["data"])
              end)
            if invalid_input do
              conn
              |> put_status(:bad_request)
              |> json(%{error: "input data is required at index #{invalid_input}"})
            else
              case ProbMap.ProblemsContext.create_problem_with_inputs(
                     %{"description" => description, "type" => type},
                     inputs
                   ) do
                {:ok, %{problem: problem}} ->
                  conn
                  |> put_status(:created)
                  |> json(%{
                    id: problem.id,
                    description: problem.description,
                    type: problem.type,
                    inserted_at: problem.inserted_at,
                    updated_at: problem.updated_at
                  })
                {:error, :problem, changeset, _} ->
                  conn
                  |> put_status(:bad_request)
                  |> json(%{error: "invalid data", details: format_changeset_errors(changeset)})
                {:error, :data_of_problems, changeset, _} ->
                  conn
                  |> put_status(:bad_request)
                  |> json(%{error: "invalid input data", details: format_changeset_errors(changeset)})
              end
            end
          true ->
            case ProbMap.ProblemsContext.create_problem(%{"description" => description, "type" => type}) do
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
  end

  @spec types(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def types(conn, _) do
    conn |> json([
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

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id} = params) do
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
        case Integer.parse(id) do
          {int_id, ""} when int_id > 0 ->
            case ProbMap.ProblemsContext.get_problem(int_id) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Problem not found"})
              problem ->
                case ProbMap.ProblemsContext.update_problem(problem, %{"description" => description, "type" => type}) do
                  {:ok, _updated} ->
                    send_resp(conn, :no_content, "")
                  {:error, changeset} ->
                    conn
                    |> put_status(:bad_request)
                    |> json(%{error: "invalid data", details: format_changeset_errors(changeset)})
                end
            end
          _ ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "id must be a positive integer"})
        end
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int_id, ""} when int_id > 0 ->
        case ProbMap.ProblemsContext.get_problem(int_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Problem not found"})
          problem ->
            case ProbMap.ProblemsContext.delete_problem(problem) do
              {:ok, _deleted} ->
                send_resp(conn, :no_content, "")
              {:error, changeset} ->
                conn
                |> put_status(:bad_request)
                |> json(%{error: "failed to delete", details: format_changeset_errors(changeset)})
            end
        end
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "id must be a positive integer"})
    end
  end
end
