defmodule HLDSRcon.RconClient do
  use GenServer

  alias HLDSRcon.ServerInfo

  @message_start "\xff\xff\xff\xff"
  @message_end "\n"

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(%ServerInfo{} = server) do
    {:ok, socket} = :gen_udp.open(0)
    {
      :ok,
      %{
        server: server,
        socket: socket
      }
    }
  end

  def handle_call({:command, command}, _from, %{
    server: server,
    socket: socket
  } = state) do
    challenge = socket |> get_challenge(server)
    result = socket |> handle_command(server, challenge, command)
    {:reply, {:ok, result}, state}
  end

  defp handle_command(socket, server, challenge, "stats") do
    [_col_headers | [values | _]] = send_command(socket, server, challenge, "stats")
    |> String.replace(~r/ +/, " ", global: true)
    |> String.split("\n")
    [
      value_cpu,
      value_in,
      value_out,
      value_up,
      value_users,
      value_fps,
      value_players
    ] = values
        |> String.split(" ")
        |> Enum.map(&Float.parse/1)
        |> Enum.map(fn {val, _} -> val end)
    %HLDSRcon.Stats{
      cpu: value_cpu,
      in: value_in,
      out: value_out,
      uptime: value_up,
      users: value_users,
      fps: value_fps,
      players: value_players
    }
  end

  defp handle_command(socket, server, challenge, command) do
    send_command(socket, server, challenge, command)
  end

  defp send_command(socket, %ServerInfo{
    host: host,
    port: port,
    password: password
  }, challenge, command) do
    command_data = (@message_start <> "rcon " <> challenge <> " " <> password <> " " <> command <> @message_end)
                   |> :binary.bin_to_list
    :gen_udp.send(socket, host |> String.to_charlist, port, command_data)
    {:ok, {_address, _port, @message_start <> data}} = :gen_udp.recv(socket, 0, Application.get_env(:hlds_rcon, :timeout))
    data |> String.slice(5..-3)
  end

  defp get_challenge(socket, %ServerInfo{
    host: host,
    port: port
  }) do
    command_data = (@message_start <> "getchallenge" <> @message_end)
                   |> :binary.bin_to_list
    :gen_udp.send(socket, host |> String.to_charlist, port, command_data)
    {:ok, {_address, _port, @message_start <> data}} = :gen_udp.recv(socket, 0, Application.get_env(:hlds_rcon, :timeout))
    [_ | [challenge | _]] = data |> String.slice(0..-3) |> String.split(" ")
    challenge
  end

end