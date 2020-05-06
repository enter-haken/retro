defmodule Retro.Participant do
  alias __MODULE__

  alias Retro.Session
  alias Retro.Entry

  @type kind :: :creator | :participant

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          is_creator: boolean()
        }

  defstruct id: nil,
            name: "anonymous",
            is_creator: false

  def create(is_creator: true),
    do: %Participant{id: UUID.uuid4(), is_creator: true}

  def create(),
    do: %Participant{id: UUID.uuid4()}

  def get(%Participant{id: id, name: name, is_creator: is_creator}),
    do: %{
      id: id,
      name: name,
      isCreator: is_creator
    }

  def update(
        %Session{
          id: session_id,
          participants: participants,
          entries: entries
        },
        %Participant{
          id: participant_id_to_update,
          name: name
        }
      ) do
    participant_to_update =
      participants
      |> Enum.find(fn %Participant{id: id} -> id == participant_id_to_update end)

    %Session{
      id: session_id,
      participants:
        participants
        |> Enum.reduce([], fn %Participant{id: id} = current_participant, acc ->
          participant =
            cond do
              id == participant_id_to_update ->
                %Participant{current_participant | name: name}

              true ->
                current_participant
            end

          acc ++ [participant]
        end),
      entries:
        entries
        |> Enum.reduce([], fn %Entry{participant: %Participant{id: participant_id}} =
                                current_entry,
                              acc ->
          entry =
            cond do
              participant_id == participant_id_to_update ->
                %Entry{
                  current_entry
                  | participant: %Participant{participant_to_update | name: name}
                }

              true ->
                current_entry
            end

          acc ++ [entry]
        end)
    }
  end

  def update(nil, _participant), do: nil

  def update(_session, _participant), do: nil
end
