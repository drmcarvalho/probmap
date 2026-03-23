defmodule ProbMap.CoreLogic do
  @moduledoc """
  Pure functions for core business logic.
  """

  @doc """
  Checks if a string is blank (nil, empty, or only whitespace).

  ## Examples

      iex> ProbMap.CoreLogic.blank?(nil)
      true

      iex> ProbMap.CoreLogic.blank?("")
      true

      iex> ProbMap.CoreLogic.blank?("   ")
      true

      iex> ProbMap.CoreLogic.blank?("hello")
      false
  """
  @spec blank?(String.t() | nil) :: boolean()
  def blank?(nil), do: true
  def blank?(str) when is_binary(str), do: String.trim(str) == ""
end
