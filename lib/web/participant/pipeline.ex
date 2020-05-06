defmodule Retro.Web.Participant.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :retro,
    module: Retro.Web.Token,
    error_handler: Retro.Web.AuthErrorHandler

  #plug(Guardian.Plug.VerifyHeader)
  plug(Retro.Web.Plug.Populate)
end
