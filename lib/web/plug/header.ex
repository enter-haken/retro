defmodule Retro.Web.Plug.Header do
  import Plug.Conn

  @behaviour Plug

  def call(conn, _opts) do
    conn
    |> put_resp_header("Cache-Control","no-cache")
  end

  def init(opts), do: opts
end
