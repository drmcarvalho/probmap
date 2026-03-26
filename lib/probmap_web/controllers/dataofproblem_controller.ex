defmodule ProbMapWeb.DataOfProblemController do
  use ProbMapWeb, :controller

  @spec criteria(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def criteria(conn, %{"id" => id} = params) do
    case Integer.parse(id) do
      {int_id, ""} when int_id > 0 ->
        search_term = params["q"]
        result =
          ProbMap.ProblemsContext.search_data_of_problems(int_id, search_term)
          |> Enum.map(fn d -> %{
              data: d.data,
              dataId: d.id,
              problemId: d.problem_id
            }
          end)
        conn |> json(result)
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "id must be a positive integer"})
    end
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"id" => id} = params) do
    case Integer.parse(id) do
      {int_id, ""} when int_id > 0 ->
        data = params["data"]
        unknown_keys = Map.keys(params) -- ["id", "data"]
        cond do
          unknown_keys != [] ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "unknown field: #{Enum.join(unknown_keys, ", ")}"})
          ProbMap.CoreLogic.blank?(data) ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "data is required"})
          true ->
            case ProbMap.ProblemsContext.get_problem(int_id) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Problem not found"})
              problem ->
                case ProbMap.ProblemsContext.create_data_of_problem(problem, %{"data" => data}) do
                  {:ok, _} ->
                    send_resp(conn, :created, "")
                  {:error, _} ->
                    conn
                    |> put_status(:bad_request)
                    |> json(%{error: "failed to create data of problem"})
                end
            end
        end
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "id must be a positive integer"})
    end
  end
end
