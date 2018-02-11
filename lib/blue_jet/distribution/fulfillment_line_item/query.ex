defmodule BlueJet.Distribution.FulfillmentLineItem.Query do
  use BlueJet, :query

  alias BlueJet.Distribution.FulfillmentLineItem

  @filterable_fields [
    :source_type,
    :source_id,
    :fulfillment_id
  ]

  def default() do
    from fli in FulfillmentLineItem
  end

  def for_account(query, account_id) do
    from fli in query, where: fli.account_id == ^account_id
  end

  def filter_by(query, filter) do
    filter_by(query, filter, @filterable_fields)
  end

  def preloads(_, _) do
    []
  end
end