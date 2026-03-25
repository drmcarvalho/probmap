defmodule ProbMap.Repo.Migrations.CreateDataOfProblems do
  use Ecto.Migration

  def change do
    create table(:data_of_problems) do
      add :data, :string

      add :problem_id, references(:problems, on_delete: :delete_all, on_update: :update_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:data_of_problems, [:problem_id])
  end
end
