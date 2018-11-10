# HLDSRcon

  [![Build Status](https://travis-ci.org/JonnyPower/hlds_rcon.svg?branch=master)](https://travis-ci.org/JonnyPower/hlds_rcon)
  [![Hex.pm](https://img.shields.io/hexpm/v/hlds_rcon.svg)](https://hex.pm/packages/hlds_rcon)

  A elixir library for creating Half-Life Dedicated Server (a.k.a "HLDS") remote connections (a.k.a "rcon") 
  and executing commands.

## Installation

The package can be installed by adding `hlds_rcon` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hlds_rcon, "~> 1.0.0"}
  ]
end
```

## Quickstart

  If you are running a server on the localhost with the HLDS `rcon_password` set to `Foo`, you would connect;

    {:ok, _pid} = HLDSRcon.connect("127.0.0.1", "Foo")

  Now that the connection is established, you can run commands;

    {:ok, _response} = HLDSRcon.command("127.0.0.1", "echo Test")

  Some common command responses are processed into structs for ease of use;

    {:ok, %HLDSRcon.Stats{} = stats} = HLDSRcon.command("127.0.0.1", "stats")

  These common commands also have entry points in this class, e.g. instead of calling command to run stats as above,
  we could simply call;

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


## Documentation

HexDocs at [https://hexdocs.pm/hlds_rcon](https://hexdocs.pm/hlds_rcon).

