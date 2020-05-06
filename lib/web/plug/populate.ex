defmodule Retro.Web.Plug.Populate do
  import Plug.Conn

  alias Retro.{Session, SessionWorker, Participant}

  require Logger

  @behaviour Plug

  def call(%Plug.Conn{req_headers: req_headers} = conn, _opts) do
    with {"authorization", "Bearer " <> token} <- List.keyfind(req_headers, "authorization", 0),
         {:ok,
          %{
            "sub" => %{
              "session" => session_id,
              "user" => user_id
            }
          }} <- Retro.Token.decode_and_verify(token),
         {:ok, %Session{participants: participants} = session} <- SessionWorker.get(session_id) do
      user =
        participants
        |> Enum.find(fn %Participant{id: id} -> id == user_id end)

      conn
      |> assign(:user, user)
      |> assign(:session, session)
    else
      {:error, :unknown, session_id} ->
        if EventBus.topic_exist?(session_id |> String.to_atom()) do
          EventBus.unsubscribe(session_id |> String.to_atom())
          Logger.info("session #{session_id} does not exist. The topic has been removed from EventBus")
        end
        conn
        |> send_resp(401, "not authorized")
        |> halt()


      err ->
        Logger.warn("error during authorization check: #{inspect(err, pretty: true)}")

        conn
        |> send_resp(401, "not authorized")
        |> halt()
    end
  end

  def init(opts), do: opts
end
