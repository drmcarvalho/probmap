defmodule ProbMapWeb.ProblemController do
  use ProbMapWeb, :controller

  def index(conn, _params) do
    json(conn, %{method: "GET", action: "/api/problem"})
  end

  def criteria(conn, _params) do
    json(conn, %{method: "GET", action: "/api/problem/criteria"})
  end

  def create(conn, _params) do
    json(conn, %{method: "POST", action: "/api/problem"})
  end

  def update(conn, _params) do
    json(conn, %{method: "PUT", action: "/api/problem"})
  end

  def delete(conn, _params) do
    json(conn, %{method: "DELETE", action: "/api/problem"})
  end
end
