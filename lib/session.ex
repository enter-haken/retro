defmodule Retro.Session do
  alias Retro.{Session, Participant, Entry}
  alias SSE.Chunk
  alias EventBus.Model.Event

  require Logger

  @type t :: %__MODULE__{
          id: String.t(),
          participants: [Retro.Participant.t()],
          entries: [Retro.Entry.t()],
          latest_activity: DateTime.t()
        }

  @two_hours 2 * 60 * 60

  defstruct id: UUID.uuid4(),
            participants: [],
            entries: [],
            latest_activity: nil

  def create(),
    do: %Session{
      id: UUID.uuid4(),
      participants: [Participant.create(is_creator: true)],
      latest_activity: DateTime.utc_now()
    }

  def get(%Session{id: id, participants: participants, entries: entries} = session) do
    %{
      id: id,
      participants: participants |> Enum.map(&Participant.get/1),
      entries: entries |> Enum.map(&Entry.get/1),
      latest_activity: seconds_since_latest_activity(session)
    }
  end
  
  defp seconds_since_latest_activity(%Session{latest_activity: latest_activity}) do
    DateTime.diff(DateTime.utc_now(), latest_activity)
  end

  def active(session), do: %Session{session | latest_activity: DateTime.utc_now()}

  def is_to_old?(%Session{latest_activity: latest_activity}) do
    DateTime.diff(DateTime.utc_now(), latest_activity) > @two_hours
  end

  def needs_update(%Session{id: id}) do
    Logger.debug("session #{id} should be updated")

    EventBus.notify(%Event{
      id: UUID.uuid4(),
      data: %Chunk{data: true, retry: 5_000},
      topic: id |> String.to_atom(),
    })
  end
end
