defmodule ProbMap.Repo.Migrations.CreateProblems do
  use Ecto.Migration

  def change do
    create table(:problems) do
      add :description, :string
      add :type, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
