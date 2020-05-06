defmodule Retro.Web.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  require Logger

  import Plug.Conn

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, reason}, _opts) do
    Logger.debug(
      "conn: #{inspect(conn, pretty: true)}, type: #{inspect(type)}, reason: #{inspect(reason)}"
    )

    conn
    |> send_resp(401, "Unauthorized")
    |> halt()
  end
end
