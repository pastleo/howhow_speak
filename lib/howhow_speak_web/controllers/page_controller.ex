defmodule HowhowSpeakWeb.PageController do
  use HowhowSpeakWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def sounds(conn, %{"text" => text}) do
    crptransfer_sounds(text)
    |> attatch_sounds_time()
    |> (&%{"sounds" => &1}).()
    |> (&json(conn, &1)).()
  end
  def chewin(conn, _params) do
    json(conn, %{"sounds" => []})
  end

  @crptransfer_uri_base %URI{
    scheme: "https",
    host: "crptransfer.moe.gov.tw",
    path: "/index.jsp",
    query: "",
  }

  defp crptransfer_sounds(text) do
    %URI{
      @crptransfer_uri_base |
      query: URI.encode_query(%{"SN" => text, "sound" => "1"}),
    }
    |> to_string()
    |> HTTPoison.get([], hackney: [:insecure])
    |> crptransfer_response_body()
    |> crptransfer_parse_body()
  end

  defp crptransfer_response_body(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      err_response ->
        IO.inspect({:err, err_response})
        ""
    end
  end

  defp crptransfer_parse_body(body) do
    Regex.run(
      ~r/<tr><th axis='資料類型'>漢語拼音<\/th><td>.*<\/td><\/tr>/,
      body
    )
    |> crptransfer_parse_body_sounds()
  end

  defp crptransfer_parse_body_sounds([sounds_html | _]) do
    Regex.scan(~r/<span class=long>([^<]+ ?)+<\/span>/, sounds_html)
    |> Enum.map(&Enum.at(&1, 1))
    |> Enum.flat_map(&String.split(&1, " "))
    |> Enum.map(&extract_accent/1)
  end

  defp crptransfer_parse_body_sounds(_) do
    []
  end

  @characters_accent %{
    'ā' => {'a', 1}, 'ē' => {'e', 1}, 'ī' => {'i', 1}, 'ō' => {'o', 1}, 'ū' => {'u', 1},
    'á' => {'a', 2}, 'é' => {'e', 2}, 'í' => {'i', 2}, 'ó' => {'o', 2}, 'ú' => {'u', 2},
    'ǎ' => {'a', 3}, 'ě' => {'e', 3}, 'ǐ' => {'i', 3}, 'ǒ' => {'o', 3}, 'ǔ' => {'u', 3},
    'à' => {'a', 4}, 'è' => {'e', 4}, 'ì' => {'i', 4}, 'ò' => {'o', 4}, 'ù' => {'u', 4},
  }

  defp extract_accent(pinyin) do
    String.to_charlist(pinyin)
    |> extract_accent_recur(0, '')
  end

  defp extract_accent_recur([char | rest_pinyin], accent, new_pinyin) do
    case Map.get(@characters_accent, [char]) do
      {[replace_char], new_accent} ->
        extract_accent_recur(rest_pinyin, new_accent, [replace_char | new_pinyin])
      _ ->
        extract_accent_recur(rest_pinyin, accent, [char | new_pinyin])
    end
  end
  defp extract_accent_recur([], accent, new_pinyin) do
    "#{to_string(new_pinyin) |> String.reverse()}#{accent}"
  end

  defp attatch_sounds_time(sounds) do
    sounds
    |> Enum.map(&HowhowSpeak.SoundTime.get/1)
  end
end
