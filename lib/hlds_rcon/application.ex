defmodule HLDSRcon.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: HLDSRcon.ClientSupervisor, strategy: :one_for_one}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end