defmodule HLDSRcon.Application do
  use Application

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HLDSRcon.Application]
    Supervisor.start_link(children, opts)
  end

end
