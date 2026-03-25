defmodule ProbMap.Problems.BinaryRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "binary_relationships" do
    field :bit, :boolean, default: false

    belongs_to :data_of_problem, ProbMap.Problems.DataOfProblem
    belongs_to :result_transform, ProbMap.Problems.ResultTransform

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(binary_relationship, attrs) do
    binary_relationship
    |> cast(attrs, [:bit])
    |> validate_required([:bit])
    |> assoc_constraint(:data_of_problem)
    |> assoc_constraint(:result_transform)
  end
end
