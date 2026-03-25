defmodule ProbMap.Repo.Migrations.CreateResultTransforms do
  use Ecto.Migration

  def change do
    create table(:result_transforms) do
      add :result, :string

      add :problem_id, references(:problems, on_delete: :delete_all, on_update: :update_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:result_transforms, [:problem_id])
  end
end
