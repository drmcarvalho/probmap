defmodule ProbMap.Problems do
  @moduledoc """
  Contexto para operações com Problems e entidades relacionadas.
  """

  import Ecto.Query
  alias ProbMap.Repo
  alias ProbMap.Problems.{Problem, DataOfProblem, ResultTransform, BinaryRelationship}

  # --- Problem ---

  def list_problems do
    Repo.all(Problem)
  end

  def search_problems(search_term) do
    query =
      if search_term && String.trim(search_term) != "" do
        wildcard = "%#{search_term}%"
        from(p in Problem, where: like(p.description, ^wildcard))
      else
        from(p in Problem)
      end

    Repo.all(query)
  end

  def get_problem(id) do
    Repo.get(Problem, id)
  end

  def get_problem!(id) do
    Repo.get!(Problem, id)
  end

  def create_problem(attrs \\ %{}) do
    %Problem{}
    |> Problem.changeset(attrs)
    |> Repo.insert()
  end

  def update_problem(%Problem{} = problem, attrs) do
    problem
    |> Problem.changeset(attrs)
    |> Repo.update()
  end

  def delete_problem(%Problem{} = problem) do
    Repo.delete(problem)
  end

  # --- DataOfProblem ---

  def list_data_of_problems(problem_id) do
    from(d in DataOfProblem, where: d.problem_id == ^problem_id)
    |> Repo.all()
  end

  def create_data_of_problem(%Problem{} = problem, attrs \\ %{}) do
    problem
    |> Ecto.build_assoc(:data_of_problems)
    |> DataOfProblem.changeset(attrs)
    |> Repo.insert()
  end

  # --- ResultTransform ---

  def list_result_transforms(problem_id) do
    from(r in ResultTransform, where: r.problem_id == ^problem_id)
    |> Repo.all()
  end

  def create_result_transform(%Problem{} = problem, attrs \\ %{}) do
    problem
    |> Ecto.build_assoc(:result_transforms)
    |> ResultTransform.changeset(attrs)
    |> Repo.insert()
  end

  # --- BinaryRelationship ---

  def list_binary_relationships(data_of_problem_id) do
    from(b in BinaryRelationship, where: b.data_of_problem_id == ^data_of_problem_id)
    |> Repo.all()
  end

  def create_binary_relationship(
        %DataOfProblem{} = data,
        %ResultTransform{} = result,
        attrs \\ %{}
      ) do
    %BinaryRelationship{data_of_problem_id: data.id, result_transform_id: result.id}
    |> BinaryRelationship.changeset(attrs)
    |> Repo.insert()
  end
end
