defmodule Retro.Web.Participant.Router do
  use Plug.Router
  import Retro.Web.Response

  require Logger

  alias Retro.{Session, Entry, Participant, SessionWorker, SessionSupervisor}

  plug(Retro.Web.Participant.Pipeline)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json, :multipart],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get "/" do
    %Session{id: session_id} = conn.assigns[:session]

    # always read the last known state from the worker.
    {:ok, session} =
      session_id
      |> SessionWorker.get()

    conn
    |> send_resp(
      200,
      session
      |> Session.get()
      |> to_response()
    )
  end

  put "/" do
    %Session{id: session_id} = conn.assigns[:session]

    %Plug.Conn{
      params: %{"name" => name}
    } = conn

    case SessionWorker.update_participant(session_id, %Participant{
           conn.assigns[:user]
           | name: name
         }) do
      {:ok, _} ->
        conn
        |> notify_session_has_updated()
        |> send_resp(200, :ok |> to_response())

      _ ->
        conn |> send_resp(404, "could not update participant" |> to_error())
    end
  end

  delete "/" do
    %Session{id: session_id} = session = conn.assigns[:session]
    %Participant{id: participant_id, is_creator: is_creator} = conn.assigns[:user]

    if is_creator do
      case SessionSupervisor.delete(session) do
        {:ok, _} ->
          conn |> send_resp(200, :ok |> to_response())

        _ ->
          conn
          |> send_resp(404, "could not delete session #{session_id}" |> to_response())
      end
    else
      case SessionWorker.delete_participant(session_id, participant_id) do
        {:ok, _} ->
          conn |> send_resp(200, :ok |> to_response())

        _ ->
          conn
          |> send_resp(404, "could not delete participant #{participant_id}" |> to_response())
      end
    end
  end

  post "/entry" do
    %Session{id: session_id} = conn.assigns[:session]

    %Plug.Conn{
      params: %{"text" => text, "entryKind" => entry_kind}
    } = conn

    case SessionWorker.create_entry(
           session_id,
           Entry.create(text, entry_kind, conn.assigns[:user])
         ) do
      {:ok, _} ->
        conn
        |> notify_session_has_updated()
        |> send_resp(200, :ok |> to_response())

      _ ->
        conn
        |> send_resp(
          404,
          "could not crete enry for session #{session_id} and user #{conn.assigns[:user]}"
          |> to_response()
        )
    end
  end

  put "/entry" do
    %Session{id: session_id} = conn.assigns[:session]

    %Plug.Conn{
      params: %{"text" => text, "id" => id}
    } = conn

    case SessionWorker.update_entry(session_id, %Entry{id: id, text: text}) do
      {:ok, _} ->
        conn
        |> notify_session_has_updated()
        |> send_resp(200, :ok |> to_response())

      _ ->
        conn |> send_resp(404, "could not update entry #{id}" |> to_response())
    end
  end

  delete "/entry/:entry_id" do
    %Session{id: session_id} = conn.assigns[:session]

    case SessionWorker.delete_entry(session_id, entry_id) do
      {:ok, _} ->
        conn
        |> notify_session_has_updated()
        |> send_resp(200, :ok |> to_response())

      _ ->
        conn |> send_resp(404, "could not delete entry #{entry_id}" |> to_response())
    end
  end

  put "/entry/:entry_id/vote" do
    %Session{id: session_id} = conn.assigns[:session]

    case SessionWorker.vote_entry(session_id, entry_id) do
      {:ok, _} ->
        conn
        |> notify_session_has_updated()
        |> send_resp(200, :ok |> to_response())

      _ ->
        conn |> send_resp(404, "could not vote on entry #{entry_id}" |> to_response())
    end
  end

  defp notify_session_has_updated(conn) do
    conn.assigns[:session]
    |> Session.needs_update()

    conn
  end
end
