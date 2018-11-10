defmodule HLDSRcon.RconClient do
  use GenServer

  alias HLDSRcon.ServerInfo

  @message_start "\xff\xff\xff\xff"
  @message_end "\n"
  @default_timeout 60000

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

  # Server

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

  def handle_call({:command, command}, _from, %{
    server: server,
    socket: socket,
    opts: opts
  } = state) do
    challenge = socket |> get_challenge(server, opts)
    result = socket |> handle_command(server, challenge, command, opts)
    {:reply, {:ok, result}, state}
  end

  defp handle_command(socket, server, challenge, "stats", opts) do
    [_col_headers | [values | _]] = send_command(socket, server, challenge, "stats", opts)
    |> String.replace(~r/ +/, " ", global: true)
    |> String.split("\n")

    values
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> HLDSRcon.Stats.from
  end

  defp handle_command(socket, server, challenge, command, opts) do
    send_command(socket, server, challenge, command, opts)
  end

  defp send_command(socket, %ServerInfo{
    host: host,
    port: port,
    password: password
  }, challenge, command, opts) do
    command_data = (@message_start <> "rcon " <> challenge <> " " <> password <> " " <> command <> @message_end)
                   |> :binary.bin_to_list
    :ok = :gen_udp.send(socket, host |> String.to_charlist, port, command_data)

    timeout = Keyword.get(opts, :timeout, @default_timeout)
    {:ok, {_address, _port, @message_start <> data}} = :gen_udp.recv(socket, 0, timeout)
    processed_response = data |> String.slice(5..-3)
    IO.puts(processed_response)
    processed_response
  end

  defp get_challenge(socket, %ServerInfo{
    host: host,
    port: port
  }, opts) do
    command_data = (@message_start <> "getchallenge" <> @message_end)
                   |> :binary.bin_to_list
    :ok = :gen_udp.send(socket, host |> String.to_charlist, port, command_data)

    timeout = Keyword.get(opts, :timeout, @default_timeout)
    {:ok, {_address, _port, @message_start <> data}} = :gen_udp.recv(socket, 0, timeout)
    [_ | [challenge | _]] = data |> String.slice(0..-3) |> String.split(" ")
    challenge
  end

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