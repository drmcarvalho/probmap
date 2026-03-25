defmodule ProbMap.Problems.DataOfProblem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "data_of_problems" do
    field :data, :string

    belongs_to :problem, ProbMap.Problems.Problem
    has_many :binary_relationships, ProbMap.Problems.BinaryRelationship

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(data_of_problem, attrs) do
    data_of_problem
    |> cast(attrs, [:data])
    |> validate_required([:data])
    |> assoc_constraint(:problem)
  end
end
