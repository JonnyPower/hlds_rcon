defmodule HLDSRcon do
  @moduledoc """
  A module for creating Half-Life Dedicated Server (a.k.a "HLDS") remote connections (a.k.a "rcon") and execting commands.

  This module uses a `DynamicSupervisor` for connecting clients. If you want to manage the rcon client supervision
  yourself you can use the `HLDSRcon.RconClient` module directly.

  ## Examples

  If you are running a server on the localhost with the HLDS `rcon_password` set to `Foo`, you would connect;

    ```
    {:ok, _pid} = HLDSRcon.connect("127.0.0.1", "Foo")
    ```

  Now that the connection is established, you can run commands;

    ```
    {:ok, _response} = HLDSRcon.command("127.0.0.1", "echo Test")
    ```

  Some common command responses are processed into structs for ease of use;

    ```
    {:ok, %HLDSRcon.Stats{} = stats} = HLDSRcon.command("127.0.0.1", "stats")
    ```

  These common commands also have entry points in this class, e.g. instead of calling command to run stats as above,
  we could simply call;

    ```
    iex(1)> HLDSRcon.stats("127.0.0.1")
    {:ok,
    %HLDSRcon.Stats{
     cpu: 11.33,
     fps: 921.12,
     in: 0.0,
     out: 0.0,
     players: 0,
     uptime: 895,
     users: 0
    }}
    ```

  """

  @type host() :: String.t()

  alias HLDSRcon.ServerInfo
  alias HLDSRcon.RconClient

  @doc """
  Connect to a HLDS server, using the `HLDSRcon.ServerInfo` struct to specify server information
  """
  @spec connect(%ServerInfo{}) ::
          {:ok, pid()}
          | {:error, atom()}
  def connect(%ServerInfo{} = server_info) do
    DynamicSupervisor.start_child(HLDSRcon.ClientSupervisor, {RconClient, server_info})
  end

  @doc """
  Connect to a HLDS server at host with password, default port will be used
  """
  @spec connect(host(), String.t()) ::
          {:ok, pid()}
          | {:error, atom()}
  def connect(host, password) when is_binary(password) do
    connect(host, ServerInfo.default_port, password)
  end

  @doc """
  Connect to a HLDS server at host:port with password
  """
  @spec connect(host(), integer(), String.t()) ::
          {:ok, pid()}
          | {:error, atom()}
  def connect(host, port, password) when is_integer(port) do
    connect(%ServerInfo{
      host: host,
      port: port,
      password: password
    })
  end

  @doc """
  Get result of running rcon `stats` command on a connected server, using the default port
  """
  @spec stats(host()) ::
          {:ok, HLDSRcon.ServerInfo.t()}
          | {:error, atom()}
  def stats(host) do
    stats(host, ServerInfo.default_port)
  end

  @doc """
  Get the result of running rcon `stats` on a connected server

  Returning: `{:ok, %HLDSRcon.Stats{}}` when successful

  Returning: `{:error, reason}` when unsuccessful
  """
  @spec stats(host(), integer()) ::
          {:ok, HLDSRcon.ServerInfo.t()}
          | {:error, atom()}
  def stats(host, port) do
    case :global.whereis_name(host <> ":" <> Integer.to_string(port)) do
      :undefined -> {:error, :not_connected}
      _pid -> RconClient.stats(host, port)
    end
  end

  @doc """
  Run an arbitrary rcon command on a connected server, using the default port
  """
  @spec command(host(), String.t()) ::
          {:ok, String.t()}
          | {:error, atom()}
  def command(host, command) when is_binary(command) do
    command(host, ServerInfo.default_port, command)
  end

  @doc """
  Run an arbitrary rcon command on a connected server

  Returning: `{:ok, raw_response}` when successful

  Returning: `{:error, reason}` when unsuccessful
  """
  @spec command(host(), integer(), String.t()) ::
          {:ok, String.t()}
          | {:error, atom()}
  def command(host, port, command) when is_integer(port) do
    case :global.whereis_name(host <> ":" <> Integer.to_string(port)) do
      :undefined -> {:error, :not_connected}
      _pid -> RconClient.command(host, port, command)
    end
  end

  @doc """
  Cleaning disconnect a connected client at `host` with default port
  """
  @spec disconnect(host()) :: {:ok, atom()}
  def disconnect(host) do
    disconnect(host, ServerInfo.default_port)
  end


  @doc """
  Cleaning disconnect a connected client at `host`:`port`
  """
  @spec disconnect(host(), integer()) :: {:ok, atom()}
  def disconnect(host, port) when is_integer(port) do
    case :global.whereis_name(host <> ":" <> Integer.to_string(port)) do
      :undefined -> {:error, :not_connected}
      _pid -> RconClient.disconnect(host, port)
    end
  end

end
