defmodule Testebot.Consumer do

    use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
        cond do
            String.starts_with?(msg.content, "!ml") -> handleAnime(msg)
            String.starts_with?(msg.content, "!waifu") -> handleWaifu(msg)
            true -> :ignore
        end
    end
    defp handleWaifu(msg) do
        resp = HTTPoison.get!("https://api.waifu.im/random/?selected_tags=waifu")
        {:ok, map} = Poison.decode(resp.body)
        idJson = map["images"]["url"]
        Api.create_message(msg.channel_id, idJson)
    end
    defp handleAnime(msg) do
        aux = String.split(msg.content)
        id = Enum.fetch!(aux, 1)

        resp = HTTPoison.get!("https://api.jikan.moe/v4/anime/#{id}")

        {:ok, map} = Poison.decode(resp.body)
        idJson = map["data"]["title"]
        Api.create_message(msg.channel_id, "O anime pertencente a essa ID é: #{idJson}")

    end
    def handle_event(_event) do
        :noop
    end

end
