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

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "dataid" => dataid} = params) do
    data = params["data"]
    unknown_keys = Map.keys(params) -- ["id", "dataid", "data"]
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
        with {int_id, ""} when int_id > 0 <- Integer.parse(id),
             {int_dataid, ""} when int_dataid > 0 <- Integer.parse(dataid) do
          case ProbMap.ProblemsContext.get_problem(int_id) do
            nil ->
              conn
              |> put_status(:not_found)
              |> json(%{error: "Problem not found"})
            _problem ->
              case ProbMap.ProblemsContext.get_data_of_problem(int_dataid) do
                nil ->
                  conn
                  |> put_status(:not_found)
                  |> json(%{error: "Data of Problem not found"})
                data_of_problem ->
                  case ProbMap.ProblemsContext.update_data_of_problem(data_of_problem, %{"data" => data}) do
                    {:ok, _updated} ->
                      send_resp(conn, :no_content, "")
                    {:error, _changeset} ->
                      conn
                      |> put_status(:bad_request)
                      |> json(%{error: "failed to update data of problem"})
                  end
              end
          end
        else
          _ ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "id must be a positive integer"})
        end
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
                    conn
                    |> send_resp(:created, "")
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

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id, "dataid" => dataid}) do
    with {int_id, ""} when int_id > 0 <- Integer.parse(id),
         {int_dataid, ""} when int_dataid > 0 <- Integer.parse(dataid) do
      case ProbMap.ProblemsContext.get_problem(int_id) do
        nil ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "Problem not found"})
        _problem ->
          case ProbMap.ProblemsContext.get_data_of_problem(int_dataid) do
            nil ->
              conn
              |> put_status(:not_found)
              |> json(%{error: "Data of Problem not found"})
            data_of_problem ->
              case ProbMap.ProblemsContext.delete_data_of_problem(data_of_problem) do
                {:ok, _deleted} ->
                  send_resp(conn, :no_content, "")
                {:error, _changeset} ->
                  conn
                  |> put_status(:bad_request)
                  |> json(%{error: "failed to delete data of problem"})
              end
          end
      end
    else
      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "id must be a positive integer"})
    end
  end

end
