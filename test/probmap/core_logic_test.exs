defmodule ProbMap.CoreLogicTest do
  use ExUnit.Case, async: true

  alias ProbMap.CoreLogic

  describe "blank?/1" do
    test "returns true for nil" do
      assert CoreLogic.blank?(nil)
    end

    test "returns true for empty string" do
      assert CoreLogic.blank?("")
    end

    test "returns true for whitespace-only string" do
      assert CoreLogic.blank?("   ")
      assert CoreLogic.blank?("\t")
      assert CoreLogic.blank?("\n")
      assert CoreLogic.blank?("  \t\n  ")
    end

    test "returns false for non-blank string" do
      refute CoreLogic.blank?("hello")
      refute CoreLogic.blank?(" hello ")
    end
  end
end
