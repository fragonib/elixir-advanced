defimpl Enumerable, for: Midi do
  def count(midi) do
    frame_count = Enum.reduce(midi, 0, fn _, count -> count + 1 end)
    {:ok, frame_count}
  end

  def reduce(%Midi{content: content}, state, fun) do
    _reduce(content, state, fun)
  end

  def _reduce(_content, {:halt, acc}, _fun) do
    {:halted, acc}
  end

  def _reduce(content, {:suspend, acc}, fun) do
    {:suspended, acc, &_reduce(content, &1, fun)}
  end

  def _reduce(_content = "", {:cont, acc}, _fun) do
    {:done, acc}
  end

  def _reduce(
        _content = <<
          type::binary-4,
          length::integer-32,
          data::binary-size(length),
          rest::binary
        >>,
        {:cont, acc},
        fun
      ) do
    frame = %Midi.Frame{type: type, length: length, data: data}
    _reduce(rest, fun.(frame, acc), fun)
  end

  def member?(%Midi{}, %Midi.Frame{}) do
    {:error, __MODULE__}
  end

  def slice(%Midi{}) do
    {:error, __MODULE__}
  end
end
