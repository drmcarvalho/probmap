defmodule ProbMapWeb.DataOfProblemController do
  use ProbMapWeb, :controller

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
end
