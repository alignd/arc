defmodule Arc.Storage.Local do
  def put(definition, version, {file, scope}) do
    destination_dir = definition.storage_dir(version, {file, scope})
    File.mkdir_p(destination_dir)
    {:ok, _} = File.copy(file.path, Path.join(destination_dir, file.file_name))
    file.file_name
  end

  def url(definition, version, file_and_scope, options \\ []) do
    build_local_path(definition, version, file_and_scope)
  end

  def delete(definition, version, file_and_scope) do
    build_local_path(definition, version, file_and_scope)
    |> File.rm
  end

  defp build_local_path(definition, version, file_and_scope) do
    Path.join([
      definition.storage_dir(version, file_and_scope),
      Arc.Definition.Versioning.resolve_file_name(definition, version, file_and_scope)
    ])
  end
end
