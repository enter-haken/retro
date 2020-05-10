defmodule Retro.SessionCleaner do
  use GenServer

  alias Retro.Session

  require Logger

  @clean_up_time_in_seconds 10 * 60

  def start_link(state) do
    Logger.info("#{__MODULE__} started.")
    GenServer.start_link(__MODULE__, state)
  end

  def init(_) do
    Process.send_after(self(), :find_orphaned_sessions, @clean_up_time_in_seconds * 1_000)
    {:ok, :cleaned}
  end

  def handle_info(:find_orphaned_sessions, _state) do
    Supervisor.which_children(Retro.SessionSupervisor)
    |> Enum.map(fn {session_id, _, _, _} -> session_id end)
    |> Enum.map(fn session_id -> Retro.SessionWorker.get(session_id) end)
    |> Enum.filter(fn call_response ->
      case call_response do
        {:ok, session} ->
          Session.is_to_old?(session)

        _ ->
          false
      end
    end)
    |> Enum.each(fn {:ok, %Session{id: id} = session} ->
      Logger.info("session #{id} has been terminated, after two hours of inactivity.")
      Retro.SessionSupervisor.delete(session)
    end)

    Process.send_after(self(), :find_orphaned_sessions, @clean_up_time_in_seconds * 1_000)

    {:noreply, :cleaned}
  end
end
