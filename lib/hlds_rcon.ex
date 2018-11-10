defmodule HLDSRcon do

  alias HLDSRcon.ServerInfo
  alias HLDSRcon.RconClient

  def connect(%ServerInfo{} = server, opts \\ []) do
    RconClient.start_link(server, opts)
  end

  def connect(host, password) when is_binary(password) do
    connect(host, ServerInfo.default_port, password)
  end

  def connect(host, port, password) when is_integer(port) do
    connect(%ServerInfo{
      host: host,
      port: port,
      password: password
    })
  end

  def stats(host) do
    stats(host, ServerInfo.default_port)
  end

  def stats(host, port) do
    case :global.whereis_name(host <> ":" <> Integer.to_string(port)) do
      :undefined -> {:error, :not_connected}
      _pid -> RconClient.stats(host, port)
    end
  end

  def command(host, command) when is_binary(command) do
    command(host, ServerInfo.default_port, command)
  end

  def command(host, port, command) when is_integer(port) do
    case :global.whereis_name(host <> ":" <> Integer.to_string(port)) do
      :undefined -> {:error, :not_connected}
      _pid -> RconClient.command(host, port, command)
    end
  end

end
