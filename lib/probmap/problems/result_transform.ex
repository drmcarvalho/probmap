defmodule ProbMap.Problems.ResultTransform do
  use Ecto.Schema
  import Ecto.Changeset

  schema "result_transforms" do
    field :result, :string

    belongs_to :problem, ProbMap.Problems.Problem
    has_many :binary_relationships, ProbMap.Problems.BinaryRelationship

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(result_transform, attrs) do
    result_transform
    |> cast(attrs, [:result])
    |> validate_required([:result])
    |> assoc_constraint(:problem)
  end
end
