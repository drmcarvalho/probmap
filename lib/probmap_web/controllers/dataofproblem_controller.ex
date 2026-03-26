defmodule ProbMapWeb.DataOfProblemController do
  use ProbMapWeb, :controller

  def criteria(conn, params) do
    json(conn, %{message: "Teste", q: params["q"]})
  end
end
