defmodule ArcTest.Actions.Store do
  use ExUnit.Case, async: false
  @img "test/support/image.png"
  import Mock

  defmodule DummyDefinition do
    use Arc.Actions.Store
    use Arc.Definition.Storage

    def validate({file, _}), do: String.ends_with?(file.file_name, ".png")
    def transform(_, _), do: {:noaction}
    def __versions, do: [:original, :thumb]
  end

  test "checks file existance" do
    assert DummyDefinition.store("non-existant-file.png") == {:error, :invalid_file}
  end

  test "delegates to definition validation" do
    assert DummyDefinition.store(__ENV__.file) == {:error, :invalid_file}
  end

  test "single binary argument is interpreted as file path" do
    with_mock Arc.Storage.S3, [put: fn(DummyDefinition, _, {%{file_name: "image.png", path: @img}, nil}) -> :ok end] do
      assert DummyDefinition.store(@img) == {:ok, "image.png"}
    end
  end

  test "two-tuple argument interpreted as path and scope" do
    with_mock Arc.Storage.S3, [put: fn(DummyDefinition, _, {%{file_name: "image.png", path: @img}, :scope}) -> :ok end] do
      assert DummyDefinition.store({@img, :scope}) == {:ok, "image.png"}
    end
  end

  test "map with a filename and path" do
    with_mock Arc.Storage.S3, [put: fn(DummyDefinition, _, {%{file_name: "image.png", path: @img}, nil}) -> :ok end] do
      assert DummyDefinition.store(%{filename: "image.png", path: @img}) == {:ok, "image.png"}
    end
  end

  test "two-tuple with Plug.Upload and a scope" do
    with_mock Arc.Storage.S3, [put: fn(DummyDefinition, _, {%{file_name: "image.png", path: @img}, :scope}) -> :ok end] do
      assert DummyDefinition.store({%{filename: "image.png", path: @img}, :scope}) == {:ok, "image.png"}
    end
  end
end
