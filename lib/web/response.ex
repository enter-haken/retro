defmodule Retro.Web.Response do
  @type status :: :ok | :error
  @type t :: %__MODULE__{
          status: status(),
          result: map() | String.t(),
          error: String.t()
        }

  defstruct status: :ok,
            result: nil,
            error: nil

  alias __MODULE__

  def to_response(data) do
    case %Response{
           result: data
         }
         |> Poison.encode() do
      {:ok, encoded} ->
        encoded

      _ ->
        nil
    end
  end

  def to_error(message) do
    case %Response{
           status: :error,
           error: message
         }
         |> Poison.encode() do
      {:ok, encoded} ->
        encoded

      _ ->
        nil
    end
  end
end
