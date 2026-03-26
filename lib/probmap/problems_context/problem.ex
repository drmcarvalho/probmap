defmodule ProbMap.ProblemsContext.Problem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "problems" do
    field :description, :string

    field :type, Ecto.Enum,
      values: [:undecidable, :algorithmic, :np_complete, :human_solvable, :biosolvable]

    has_many :data_of_problems, ProbMap.ProblemsContext.DataOfProblem
    has_many :result_transforms, ProbMap.ProblemsContext.ResultTransform

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(problem, attrs) do
    problem
    |> cast(attrs, [:description, :type])
    |> validate_required([:description, :type])
    |> validate_inclusion(:type, [
      :undecidable,
      :algorithmic,
      :np_complete,
      :human_solvable,
      :biosolvable
    ])
  end
end
