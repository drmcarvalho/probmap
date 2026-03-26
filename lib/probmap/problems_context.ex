defmodule ProbMap.ProblemsContext do
  @moduledoc """
  Contexto para operações com Problems e entidades relacionadas.
  """

  import Ecto.Query
  alias ProbMap.Repo
  alias ProbMap.ProblemsContext.{Problem, DataOfProblem, ResultTransform, BinaryRelationship}

  # --- Problem ---

  @spec list_problems() :: any()
  def list_problems do
    Repo.all(Problem)
  end

  @spec search_problems(false | nil | binary()) :: any()
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

  @spec get_problem(any()) :: any()
  def get_problem(id) do
    Repo.get(Problem, id)
  end

  @spec get_problem!(any()) :: any()
  def get_problem!(id) do
    Repo.get!(Problem, id)
  end

  @spec create_problem(
          :invalid
          | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: any()
  def create_problem(attrs \\ %{}) do
    %Problem{}
    |> Problem.changeset(attrs)
    |> Repo.insert()
  end

  @spec create_problem_with_inputs(
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()},
          any()
        ) :: any()
  def create_problem_with_inputs(problem_attrs, inputs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:problem, Problem.changeset(%Problem{}, problem_attrs))
    |> Ecto.Multi.run(:data_of_problems, fn repo, %{problem: problem} ->
      results =
        Enum.map(inputs, fn input ->
          problem
          |> Ecto.build_assoc(:data_of_problems)
          |> DataOfProblem.changeset(input)
          |> repo.insert()
        end)
      case Enum.find(results, &match?({:error, _}, &1)) do
        nil -> {:ok, Enum.map(results, fn {:ok, d} -> d end)}
        {:error, changeset} -> {:error, changeset}
      end
    end)
    |> Repo.transaction()
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

  @spec list_data_of_problems(any()) :: any()
  def list_data_of_problems(problem_id) do
    from(d in DataOfProblem, where: d.problem_id == ^problem_id)
    |> Repo.all()
  end

  def search_data_of_problems(problem_id, search_term) do
    if ProbMap.CoreLogic.blank?(search_term) do
      list_data_of_problems(problem_id)
    else
      wildcard = "%#{search_term}%"
      from(d in DataOfProblem, where: d.problem_id == ^problem_id and like(d.data, ^wildcard))
      |> Repo.all()
    end
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
