defmodule ProbMap.Repo.Migrations.CreateBinaryRelationships do
  use Ecto.Migration

  def change do
    create table(:binary_relationships) do
      add :bit, :boolean, default: false, null: false

      add :data_of_problem_id,
          references(:data_of_problems, on_delete: :delete_all, on_update: :update_all),
          null: false

      add :result_transform_id,
          references(:result_transforms, on_delete: :delete_all, on_update: :update_all),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:binary_relationships, [:data_of_problem_id])
    create index(:binary_relationships, [:result_transform_id])
  end
end
