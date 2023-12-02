defmodule Mix.Tasks.Create do
  use Mix.Task

  @impl Mix.Task
  def run([day]) do
    file_path = [File.cwd!(), "lib", "days", "day#{day}.ex"] |> Path.join()

    File.write(
      file_path,
      """
      defmodule Days.Day#{day} do
        @behaviour Days.Day

        @impl Days.Day
        def part_one(input) do
        end

        @impl Days.Day
        def part_two(input) do
        end
      end
      """,
      [:exclusive]
    )

    test_path = [File.cwd!(), "test", "days", "day#{day}_test.exs"] |> Path.join()

    File.write(
      test_path,
      """
      defmodule AocTest.Day#{day}Test do
        use ExUnit.Case

        alias Days.Day#{day}

        test "part_one/1 works as expected" do
          assert Day#{day}.part_one(\"\"\"
          \"\"\") == 0
        end

        test "part_two/1 works as expected" do
          assert Day#{day}.part_two(\"\"\"
          \"\"\") == 0
        end
      end
      """,
      [:exclusive]
    )

    input_path = [File.cwd!(), "priv", "inputs", "day-#{day}.txt"] |> Path.join()

    File.write(input_path, "", [:exclusive])
  end
end
