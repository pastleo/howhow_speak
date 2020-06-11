defmodule HowhowSpeak.SoundTime do
  use Agent

  def start_link(_) do
    Agent.start_link(&read_csv/0, name: __MODULE__)
  end

  def all() do
    Agent.get(__MODULE__, & &1)
  end

  def get(sound) do
    Agent.get(__MODULE__, &Map.get(&1, sound, %{}))
  end

  defp read_csv do
    File.stream!("priv/wo.csv")
    |> Enum.filter(&String.match?(&1, ~r/\w+,\d+.\d+,\d+.\d+/))
    |> Enum.map(&String.split(&1, ","))
    |> Enum.flat_map(&parse_csv_line/1)
    |> Map.new()
  end

  defp parse_csv_line([sound, start_at, end_at]) do
    sound_pair(
      sound,
      Float.parse(start_at) |> elem(0),
      Float.parse(end_at) |> elem(0)
    )
    |> List.wrap()
  end
  defp parse_csv_line(_), do: []

  defp sound_pair(sound, start_at, end_at) do
    {
      sound,
      %{
        sound: sound,
        start: start_at,
        seconds: end_at - start_at
      }
    }
  end

end
