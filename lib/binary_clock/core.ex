defmodule BinaryClock.Core do
  defstruct [:ampm, :hours, :minutes, :seconds]

  @brightness 0xFFF

  def new(%{hour: hours, minute: minutes, second: seconds}) do
    %__MODULE__{
      ampm: hours |> div(12),
      hours: hours |> rem(12),
      minutes: minutes,
      seconds: seconds
    }
  end

  def to_leds(clock) do
    [
      clock.seconds |> padded_bits() |> Enum.reverse(),
      clock.hours |> padded_bits() |> Enum.reverse(),
      clock.ampm |> padded_bits(),
      clock.minutes |> padded_bits()
    ]
    |> List.flatten()
    |> to_bytes()
  end

  defp padded_bits(number, total_length \\ 6) do
    bits = Integer.digits(number, 2)
    padding = List.duplicate(0, total_length - length(bits))

    padding ++ bits
  end

  defp to_byte(0), do: <<0::12>>
  defp to_byte(_), do: <<@brightness::12>>

  def to_bytes(list) do
    for bit <- Enum.reverse(list),
        into: <<>>,
        do: to_byte(bit)
  end
end
