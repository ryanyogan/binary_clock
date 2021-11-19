defmodule BinaryClock.Server do
  use GenServer
  @spi_bus_name "spidev0.0"

  alias BinaryClock.Core

  def start_link(time_zone \\ "US/Central") do
    GenServer.start_link(__MODULE__, time_zone, name: __MODULE__)
  end

  def tick do
    send(__MODULE__, :tick)
  end

  @impl true
  def init(time_zone) do
    {:ok, time_zone, {:continue, :open_spi}}
  end

  @impl true
  def handle_continue(:open_spi, time_zone) do
    spi = open_spi_bus()

    :timer.send_interval(1_000, :tick)

    {:noreply, %{timezone: time_zone, spi: spi}}
  end

  @impl true
  def handle_info(:tick, clock) do
    transfer_bits_to_spi_bus(clock)
    {:noreply, clock}
  end

  defp open_spi_bus(bus_name \\ @spi_bus_name) do
    {:ok, spi} = Circuits.SPI.open(bus_name)
    spi
  end

  defp transfer_bits_to_spi_bus(%{spi: spi, timezone: timezone}) do
    Circuits.SPI.transfer(spi, time_in_bytes(timezone))
  end

  defp time_in_bytes(timezone) do
    timezone
    |> DateTime.now!(Tzdata.TimeZoneDatabase)
    |> Core.new()
    |> Core.to_leds()
  end
end
