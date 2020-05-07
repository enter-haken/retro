defmodule Retro.SessionWorker do
  use GenServer

  alias Retro.Session
  alias Retro.Participant
  alias Retro.Entry

  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(%Session{id: id} = state) do
    Logger.info("session #{id} started.")

    {:ok, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  ### participant ###

  def handle_call(
        {:create, :participant, participant},
        _from,
        %Session{participants: participants} = state
      ) do
    {:reply, state,
     %Session{state | participants: participants ++ [participant]} |> Session.active()}
  end

  def handle_call(
        {:update, :participant, participant},
        _from,
        state
      ) do
    {:reply, state, state |> Participant.update(participant) |> Session.active()}
  end

  def handle_call(
        {:delete, :participant, id_to_delete},
        _from,
        %Session{participants: participants} = state
      ) do
    {:reply, state,
     %Session{
       state
       | participants:
           participants
           |> Enum.filter(fn %Participant{id: id} ->
             id != id_to_delete
           end)
     }
     |> Session.active()}
  end

  ### entry ###

  def handle_call(
        {:create, :entry, entry},
        _from,
        %Session{entries: entries} = state
      ) do
    {:reply, state, %Session{state | entries: entries ++ [entry]} |> Session.active()}
  end

  def handle_call(
        {:update, :entry, entry_to_update},
        _from,
        %Session{entries: entries} = state
      ) do
    {:reply, state,
     %Session{state | entries: Entry.update(entries, entry_to_update)} |> Session.active()}
  end

  def handle_call(
        {:delete, :entry, id_to_delete},
        _from,
        %Session{entries: entries} = state
      ) do
    {:reply, state,
     %Session{
       state
       | entries:
           entries
           |> Enum.filter(fn %Entry{id: id} ->
             id != id_to_delete
           end)
     }
     |> Session.active()}
  end

  def handle_call(
        {:vote, :entry, id_to_vote_on},
        _from,
        %Session{entries: entries} = state
      ) do
    {:reply, state,
     %Session{state | entries: Entry.vote(entries, id_to_vote_on)} |> Session.active()}
  end

  def terminate(reason, %Session{id: id, entries: entries, participants: participants}) do
    Logger.info(
      "SessionWorker terminates for #{id} with #{length(entries)} entries and #{
        length(participants)
      }. Reason: #{reason}"
    )

    topic = id |> String.to_atom()

    case EventBus.unregister_topic(topic) do
      :ok -> Logger.info("EventBus: The topic for session #{id} has been unregistered")
      _ -> Logger.warn("EventBus: Could not unregister topic for session #{id}")
    end
  end

  ### client ###

  defp call(session_id, params) do
    case session_id |> Retro.SessionSupervisor.get_pid() do
      {:ok, pid} ->
        {:ok, GenServer.call(pid, params)}

      _ ->
        {:error, :unknown, session_id}
    end
  end

  def get(session_id),
    do:
      session_id
      |> call(:get)

  def create_participant(session_id, participant),
    do:
      session_id
      |> call({:create, :participant, participant})

  def get_participant(session_id, participant_id) do
    {:ok, %Session{participants: participants}} = get(session_id)

    participants
    |> Enum.find(fn %Participant{id: id} -> id == participant_id end)
  end

  def update_participant(session_id, participant),
    do:
      session_id
      |> call({:update, :participant, participant})

  def delete_participant(session_id, participant_id),
    do:
      session_id
      |> call({:delete, :participant, participant_id})

  def create_entry(session_id, entry) do
    session_id
    |> call({:create, :entry, entry})
  end

  def update_entry(session_id, entry) do
    session_id
    |> call({:update, :entry, entry})
  end

  def vote_entry(session_id, entry_id) do
    session_id
    |> call({:vote, :entry, entry_id})
  end

  def delete_entry(session_id, entry_id),
    do:
      session_id
      |> call({:delete, :entry, entry_id})
end
