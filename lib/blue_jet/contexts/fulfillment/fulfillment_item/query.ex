defmodule BlueJet.Fulfillment.FulfillmentItem.Query do
  use BlueJet, :query

  alias BlueJet.Fulfillment.FulfillmentItem

  @filterable_fields [
    :id,
    :source_type,
    :source_id,
    :order_line_item_id,
    :fulfillment_id
  ]

  @searchable_fields [
    :name,
    :caption,
  ]

  def default() do
    from fi in FulfillmentItem
  end

  def filter_by(query, filter) do
    filter_by(query, filter, @filterable_fields)
  end

  def search(query, keyword, locale, default_locale) do
    search(query, @searchable_fields, keyword, locale, default_locale, FulfillmentItem.translatable_fields())
  end

  def preloads(_, _) do
    []
  end
end