defmodule HLDSRcon.ServerInfo do
  @moduledoc """
  A struct representing rcon connection information for a HLDS server.

  ```
  %HLDSRcon.ServerInfo{
    host: "127.0.0.1",
    port: 27015,
    password: "foo"
  }
  ```
  """

  @default_port 27015
  @doc false
  def default_port, do: @default_port

  defstruct host: "127.0.0.1", port: @default_port, password: "foo"
end