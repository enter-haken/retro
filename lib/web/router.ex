defmodule Retro.Web.Router do
  use Plug.Router

  import Retro.Web.Response

  alias Retro.{Session, Participant, SessionWorker}

  alias Retro.Web.Participant.Router, as: ParticipantRouter

  require Logger

  plug(Plug.Logger)
  plug(CORSPlug, origin: "*")
  plug(Retro.Web.Plug.Header)

  plug(Retro.Web.Plug.Bakery)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json, :multipart],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/api/session/participant", to: ParticipantRouter)

  # adds a participant to a given session
  post "/api/session/:session_id" do
    participant = Participant.create()

    case SessionWorker.create_participant(session_id, participant) do
      {:ok, session} ->
        conn
        |> send_resp(
          200,
          %{token: Retro.Token.get_token(session, participant)} |> to_response()
        )

      _err ->
        conn |> send_resp(400, "could not create participant" |> to_error())
    end
  end

  # creates a retro session with creator as first participant
  post "/api/session" do
    case Session.create()
         |> Retro.SessionSupervisor.add() do
      {:ok, session} ->
        conn
        |> send_resp(
          200,
          %{token: Retro.Token.get_token(session)} |> to_response()
        )

      _ ->
        conn |> send_resp(404, "could not create session" |> to_error())
    end
  end

  get "/api/hasChanges/:session_id" do
    topic = session_id |> String.to_atom()

    if EventBus.topic_exist?(topic) do
      Logger.debug("topic found and sending data for session_id #{session_id}")
      conn |> SSE.stream({[topic], %SSE.Chunk{data: true}})
    else
      EventBus.register_topic(topic)

      Logger.debug(
        "new topic has been created for session_id #{session_id}. sending data for session_id #{
          session_id
        }"
      )

      conn 
      |> put_resp_header("Access-Control-Allow-Origin", "*") 
      |> SSE.stream({[topic], %SSE.Chunk{data: true}})
    end
  end
end
