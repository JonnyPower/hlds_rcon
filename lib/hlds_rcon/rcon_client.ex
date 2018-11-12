defmodule HLDSRcon.RconClient do
  @moduledoc """
  A `GenServer` for creating and using a HLDS rcon connection.

  You should only call this module directly if you want to manage the suprvision of these GenServers yourself, otherwise
  `HLDSRcon` probably covers your needs.

  Call `start_link/2` with a `HLDSRcon.ServerInfo`
  """
  use GenServer

  alias HLDSRcon.ServerInfo

  @message_start "\xff\xff\xff\xff"
  @message_end "\n"
  @default_timeout 60000 # 60 Seconds

  # Client

  def start_link(%ServerInfo{} = server, opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      {server, opts},
      name: {
        :global, get_global_name(server)
      }
    )
  end

  def stats(host) do
    stats(host, ServerInfo.default_port)
  end

  def stats(host, port) do
    GenServer.call(
      {:global, get_global_name(host, port)},
      {:command, "stats"}
    )
  end

  def command(host, command) do
    command(host, ServerInfo.default_port, command)
  end

  def command(host, port, command) when is_integer(port) do
    GenServer.call(
      {:global, get_global_name(host, port)},
      {:command, command}
    )
  end

  def disconnect(host) do
    disconnect(host, ServerInfo.default_port)
  end

  def disconnect(host, port) do
    GenServer.call(
      {:global, get_global_name(host, port)},
      :disconnect
    )
  end

  # Server

  @doc false
  def init({%ServerInfo{} = server, opts}) do
    {:ok, socket} = :gen_udp.open(0, [:binary, active: false])
    {
      :ok,
      %{
        server: server,
        socket: socket,
        opts: opts
      }
    }
  end

  @doc false
  def handle_call(:disconnect, _from, %{
    socket: socket
  } = state) do
    :ok = :gen_udp.close(socket)
    {:stop, :normal, :ok, state}
  end

  @doc false
  def handle_call({:command, command}, _from, %{
    server: server,
    socket: socket,
    opts: opts
  } = state) do
    challenge = socket |> get_challenge(server, opts)
    result = socket |> handle_command(server, challenge, command, opts)
    {:reply, {:ok, result}, state}
  end

  @doc false
  defp handle_command(socket, server, challenge, "stats", opts) do
    [_col_headers | [values | _]] = send_command(socket, server, challenge, "stats", opts)
    |> String.replace(~r/ +/, " ", global: true)
    |> String.split("\n")

    values
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> HLDSRcon.Stats.from
  end

  @doc false
  defp handle_command(socket, server, challenge, command, opts) do
    send_command(socket, server, challenge, command, opts)
  end

  @doc false
  defp send_command(socket, %ServerInfo{
    host: host,
    port: port,
    password: password
  }, challenge, command, opts) do
    command_data = (@message_start <> "rcon " <> challenge <> " " <> password <> " " <> command <> @message_end)
                   |> :binary.bin_to_list
    :ok = :gen_udp.send(socket, host |> String.to_charlist, port, command_data)

    timeout = Keyword.get(opts, :timeout, @default_timeout)
    {
      :ok,
      {
        _address,
        _port,
        # Command response is <<255, 255, 255, 255>> <> "l" <> response <> garbage
        @message_start <> <<108>> <> data
      }
    } = :gen_udp.recv(socket, 0, timeout)

    data
    |> String.chunk(:printable)
    |> Enum.filter(&String.valid?/1)
    |> Enum.at(0)
  end

  @doc false
  defp get_challenge(socket, %ServerInfo{
    host: host,
    port: port
  }, opts) do
    command_data = (@message_start <> "getchallenge" <> @message_end)
                   |> :binary.bin_to_list
    :ok = :gen_udp.send(socket, host |> String.to_charlist, port, command_data)

    timeout = Keyword.get(opts, :timeout, @default_timeout)
    {
      :ok,
      {
        _address,
        _port,
        # Challenge response is <<255, 255, 255, 255>> <> "A12345678 1234567890 0\n\0"
        @message_start <> "A" <> <<_challenge_number::bytes-size(8)>> <> " " <> <<challenge::bytes-size(10)>> <> _suffix
      }
    } = :gen_udp.recv(socket, 0, timeout)
    challenge
  end

  @doc false
  defp get_global_name(%ServerInfo{
    host: host,
    port: port
  }) do
    get_global_name(host, port)
  end

  defp get_global_name(host, port) do
    host <> ":" <> Integer.to_string(port)
  end

end