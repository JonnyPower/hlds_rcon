defmodule HLDSRcon.ServerInfo do
  @default_port 27015
  def default_port, do: @default_port

  defstruct host: "127.0.0.1", port: @default_port, password: "foo"
end