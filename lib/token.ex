defmodule Retro.Token do
  use Guardian, otp_app: :retro

  defstruct session: nil,
            user: nil,
            is_creator: nil

  alias Retro.{Session, Participant, Token}

  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  def resource_from_claims(%{"sub" => resource} = _claims) do
    {:ok, resource}
  end

  def get_token(%Session{id: session_id, participants: participants}) do
    %Participant{id: participant_id} =
      participants |> Enum.find(fn %Participant{is_creator: is_creator} -> is_creator end)

    {:ok, token, _claims} =
      %Token{
        session: session_id,
        user: participant_id,
        is_creator: true
      }
      |> encode_and_sign()

    token
  end

  def get_token(%Session{id: session_id}, %Participant{id: participant_id, is_creator: is_creator}) do
    {:ok, token, _claims} =
      %Token{
        session: session_id,
        user: participant_id,
        is_creator: is_creator
      }
      |> encode_and_sign()

    token
  end
end
