defmodule Retro.SessionSupervisor do
  use Supervisor

  require Logger

  alias Retro.{Session, SessionWorker}

  def child_spec(_) do
    Supervisor.Spec.supervisor(__MODULE__, [])
  end

  def start_link() do
    Logger.info("#{__MODULE__} started.")
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = []
    Supervisor.init(children, strategy: :one_for_one)
  end

  def add(%Session{id: id} = session) do
    spec = Supervisor.child_spec({SessionWorker, session}, id: id)

    case __MODULE__
         |> Supervisor.start_child(spec) do
      {:ok, _pid} ->
        Logger.info("started new session #{id}")
        {:ok, session}

      err ->
        Logger.warn("could not start session #{id} #{inspect(err, pretty: true)}")
        {:error, "could not start session"}
    end
  end

  def get_pid(id) do
    case any?(id) do
      true ->
        {_, pid, _, _} =
          Supervisor.which_children(__MODULE__)
          |> Enum.find(fn {session_id, _, _, _} -> session_id == id end)

        {:ok, pid}

      _ ->
        {:error, :session_not_found}
    end
  end

  def count() do
    Supervisor.which_children(__MODULE__)
    |> Kernel.length()
  end

  defp any?(id) do
    Supervisor.which_children(__MODULE__)
    |> Enum.any?(fn {session_id, _, _, _} -> session_id == id end)
  end

end
