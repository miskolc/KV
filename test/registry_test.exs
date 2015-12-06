defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  test "creates buckets" do
    {:ok, registry} = KV.Registry.start_link
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end
end