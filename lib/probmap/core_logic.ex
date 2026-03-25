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

  @doc """
  Returns a human-readable description for a problem type.

  ## Examples

      iex> ProbMap.CoreLogic.classify(:undecidable)
      "No solution — undecidable"

      iex> ProbMap.CoreLogic.classify(:algorithmic)
      "Formal step-by-step solution"

      iex> ProbMap.CoreLogic.classify(:np_complete)
      "NP-Complete complexity"
  """
  @spec classify(atom()) :: String.t()
  def classify(:undecidable), do: "No solution — undecidable"
  def classify(:algorithmic), do: "Formal step-by-step solution"
  def classify(:np_complete), do: "NP-Complete complexity"
  def classify(:human_solvable), do: "Solvable by humans"
  def classify(:biosolvable), do: "Solvable by living beings"

  @doc """
  Converts a flat problem type atom to its full classification form.

  ## Examples

      iex> ProbMap.CoreLogic.to_classification(:undecidable)
      :undecidable

      iex> ProbMap.CoreLogic.to_classification(:np_complete)
      {:intermediate, :np_complete}
  """
  @spec to_classification(atom()) :: atom() | {atom(), atom()}
  def to_classification(:undecidable), do: :undecidable
  def to_classification(:algorithmic), do: :algorithmic
  def to_classification(:np_complete), do: {:intermediate, :np_complete}
  def to_classification(:human_solvable), do: {:intermediate, :human_solvable}
  def to_classification(:biosolvable), do: {:intermediate, :biosolvable}

  @doc """
  Converts a classification value to a list of strings for JSON serialization.

  ## Examples

      iex> ProbMap.CoreLogic.classification_to_list(:undecidable)
      ["undecidable"]

      iex> ProbMap.CoreLogic.classification_to_list({:intermediate, :np_complete})
      ["intermediate", "np_complete"]
  """
  @spec classification_to_list(atom() | {atom(), atom()}) :: [String.t()]
  def classification_to_list(atom) when is_atom(atom), do: [Atom.to_string(atom)]
  def classification_to_list({a, b}), do: [Atom.to_string(a), Atom.to_string(b)]
end
