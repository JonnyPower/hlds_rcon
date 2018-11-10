defmodule HLDSRcon.Stats do
  defstruct cpu: nil, fps: nil, in: nil, out: nil, players: nil, uptime: nil, users: nil

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