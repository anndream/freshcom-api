defmodule BlueJet.Notification.Trigger.Query do
  use BlueJet, :query

  alias BlueJet.Notification.Trigger

  @searchable_fields [
    :name,
    :event
  ]

  @filterable_fields [
    :id,
    :status,
    :event,
    :action_target,
    :action_type
  ]

  def default() do
    from t in Trigger
  end

  def search(query, keyword) do
    search(query, @searchable_fields, keyword)
  end

  def search(query, keyword, _, _) do
    search(query, @searchable_fields, keyword)
  end

  def filter_by(query, filter) do
    filter_by(query, filter, @filterable_fields)
  end

  def preloads(_, _) do
    []
  end
end
