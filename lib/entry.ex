defmodule Retro.Entry do
  alias __MODULE__
  alias Retro.Participant

  @type entry_kind :: :start | :stop | :continue | :less_of | :more_of
  @type t :: %__MODULE__{
          id: String.t(),
          text: String.t(),
          markdown: String.t(),
          entry_kind: entry_kind(),
          participant: Retro.Participant.t()
        }

  defstruct id: nil,
            text: nil,
            markdown: nil,
            entry_kind: nil,
            participant: nil

  def create(text, entry_kind, participant) do
    %Entry{
      id: UUID.uuid4(),
      text: text,
      entry_kind: entry_kind,
      participant: participant
    }
    |> get_markdown()
  end

  def get(%Entry{
        id: id,
        text: text,
        markdown: markdown,
        entry_kind: entry_kind,
        participant: participant
      }),
      do: %{
        id: id,
        text: text,
        markdown: markdown,
        entryKind: entry_kind,
        participant: Participant.get(participant)
      }

  def update(nil, _entry), do: nil

  def update([], _entry), do: []

  def update(entries, %Entry{id: id_to_update, text: text}) do
    entries
    |> Enum.reduce([], fn %Entry{id: id} = current_entry, acc ->
      entry =
        cond do
          id == id_to_update ->
            %Entry{current_entry | text: text}
            |> get_markdown()

          true ->
            current_entry
        end

      acc ++ [entry]
    end)
  end

  # remark:
  # https://github.com/EdOverflow/bugbounty-cheatsheet/blob/master/cheatsheets/xss.md
  # https://github.com/showdownjs/showdown/wiki/Markdown's-XSS-Vulnerability-(and-how-to-mitigate-it)
  defp get_markdown(%Entry{text: text} = entry) do
    case Earmark.as_html(text) do
      {:ok, markdown, _} ->
        %Entry{entry | markdown: markdown}

      _ ->
        %Entry{entry | markdown: text}
    end
  end
end
