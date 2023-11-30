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
      [:write]
    )
  end
end
