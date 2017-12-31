defmodule BlueJet.ContextHelpers do
  import Ecto.Query

  alias BlueJet.Identity

  def preprocess_request(request = %{ locale: locale }, endpoint) do
    case Identity.authorize_request(request, endpoint) do
      {:ok, request = %{ account: nil }} ->
        {:ok, request}

      {:ok, request = %{ account: account }} ->
        request = Map.put(request, :locale, locale || account.default_locale)
        {:ok, request}

      other -> other
    end
  end

  def underscore(nil), do: nil
  def underscore(s), do: Inflex.underscore(s)

  def listify(nil), do: []
  def listify(list), do: list

  def paginate(query, size: size, number: number) do
    limit = size
    offset = size * (number - 1)

    query
    |> limit(^limit)
    |> offset(^offset)
  end

  def search(query, _, _, _, _), do: query # TODO: remove this
  def search(query, _, nil, _, _, _), do: query
  def search(query, _, "", _, _, _), do: query

  def search(query, columns, keyword, locale, default_locale, _) when locale == default_locale do
    search_default_locale(query, columns, keyword)
  end

  def search(query, columns, keyword, locale, _, translatable_columns) do
    search_translations(query, columns, keyword, locale, translatable_columns)
  end

  def search_default_locale(query, columns, keyword) do
    keyword = "%#{keyword}%"

    Enum.reduce(columns, query, fn(column, query) ->
      from q in query, or_where: ilike(fragment("?::varchar", field(q, ^column)), ^keyword)
    end)
  end

  def search_translations(query, columns, keyword, locale, translatable_columns) do
    keyword = "%#{keyword}%"

    Enum.reduce(columns, query, fn(column, query) ->
      if Enum.member?(translatable_columns, column) do
        column = Atom.to_string(column)
        from q in query, or_where: ilike(fragment("?->?->>?", q.translations, ^locale, ^column), ^keyword)
      else
        from q in query, or_where: ilike(fragment("?::varchar", field(q, ^column)), ^keyword)
      end
    end)
  end

  def filter_by(query, filter) do
    filter = Enum.filter(filter, fn({_, value}) -> value end)

    Enum.reduce(filter, query, fn({k, v}, acc_query) ->
      if is_list(v) do
        from q in acc_query, where: field(q, ^k) in ^v
      else
        from q in acc_query, where: field(q, ^k) == ^v
      end
    end)
  end

  def ids_only(query) do
    from q in query, select: q.id
  end
end