defmodule HLDSRcon.Stats do
  @moduledoc """
  A struct representing the results of a stats call on a HLDS server.

  ```
  %HLDSRcon.Stats{
    cpu: 10.0,
    in: 1.0,
    out: 1.0,
    uptime: 1,
    users: 1,
    fps: 1000.0,
    players: 32
  }
  ```
  """
  defstruct cpu: nil, fps: nil, in: nil, out: nil, players: nil, uptime: nil, users: nil

  @doc """
  Constructs a `%HLDSRcon.Stats{}` struct from a list of string values

  Expects a list matching;

  ```
  [
    value_cpu,
    value_in,
    value_out,
    value_up,
    value_users,
    value_fps,
    value_players
  ]
  ```

  ## Example

  ```
  iex> HLDSRcon.Stats.from([
  ...>   "10.0",
  ...>   "1.0",
  ...>   "1.0",
  ...>   "1",
  ...>   "1",
  ...>   "1000.0",
  ...>   "32"
  ...> ])
  %HLDSRcon.Stats{
    cpu: 10.0,
    in: 1.0,
    out: 1.0,
    uptime: 1,
    users: 1,
    fps: 1000.0,
    players: 32
  }
  ```

  """
  @spec from(list()) :: struct()
  def from(
        [
          value_cpu,
          value_in,
          value_out,
          value_up,
          value_users,
          value_fps,
          value_players
        ]
      ) do
    with {parsed_cpu, _} <- Float.parse(value_cpu),
         {parsed_in, _} <- Float.parse(value_in),
         {parsed_out, _} <- Float.parse(value_out),
         {parsed_up, _} <- Integer.parse(value_up),
         {parsed_users, _} <- Integer.parse(value_users),
         {parsed_fps, _} <- Float.parse(value_fps),
         {parsed_players, _} <- Integer.parse(value_players)
      do
      %HLDSRcon.Stats{
        cpu: parsed_cpu,
        in: parsed_in,
        out: parsed_out,
        uptime: parsed_up,
        users: parsed_users,
        fps: parsed_fps,
        players: parsed_players
      }
    end
  end

end