defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `[:ok, pid]` if the bucket exists, `:errors` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Stop the registry
  """
  def stop(server) do
    GenServer.call(server, :stop)
  end

  ## Server Callbacks

  # Returning {:ok, state} will cause
  # start_link/3 to return {:ok, pid}
  # and the process to enter its loop.
  def init(:ok) do
    {:ok, HashDict.new}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, HashDict.fetch(names, name), names}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:create, name}, names) do
    if HashDict.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link()
      {:noreply, HashDict.put(names, name, bucket)}
    end
  end
end
