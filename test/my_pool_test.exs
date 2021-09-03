defmodule MyPoolTest do
  use ExUnit.Case
  doctest MyPool

  test "greets the world" do
    assert MyPool.hello() == :world
  end
end
