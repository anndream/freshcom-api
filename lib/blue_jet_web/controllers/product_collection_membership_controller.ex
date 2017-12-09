defmodule BlueJetWeb.ProductCollectionMembershipController do
  use BlueJetWeb, :controller

  alias JaSerializer.Params
  alias BlueJet.Catalogue

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn = %{ assigns: assigns }, params) do
    request = %AccessRequest{
      vas: assigns[:vas],
      search: params["search"],
      filter: assigns[:filter],
      pagination: %{ size: assigns[:page_size], number: assigns[:page_number] },
      preloads: assigns[:preloads],
      locale: assigns[:locale]
    }

   {:ok, %AccessResponse{ data: product_collection_memberships, meta: meta }} = Catalogue.list_product_collection_membership(request)

    render(conn, "index.json-api", data: product_collection_memberships, opts: [meta: camelize_map(meta), include: conn.query_params["include"]])
  end

  def create(conn = %{ assigns: assigns = %{ vas: vas } }, %{ "data" => data = %{ "type" => "ProductCollectionMembership" } }) do
    fields =
      Params.to_attributes(data)
      |> underscore_value(["kind", "name_sync"])

    request = %AccessRequest{
      vas: assigns[:vas],
      fields: fields,
      preloads: assigns[:preloads]
    }

    case Catalogue.create_product_collection_membership(request) do
      {:ok, %AccessResponse{ data: product_collection_membership }} ->
        conn
        |> put_status(:created)
        |> render("show.json-api", data: product_collection_membership, opts: [include: conn.query_params["include"]])
      {:error, %AccessResponse{ errors: errors }} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: extract_errors(errors))
    end
  end

  def show(conn = %{ assigns: assigns = %{ vas: vas } }, %{ "id" => id }) do
    request = %AccessRequest{
      vas: assigns[:vas],
      params: %{ id: id },
      preloads: assigns[:preloads],
      locale: assigns[:locale]
    }

    {:ok, %AccessResponse{ data: product_collection_membership }} = Catalogue.get_product_collection_membership(request)

    render(conn, "show.json-api", data: product_collection_membership, opts: [include: conn.query_params["include"]])
  end

  def update(conn = %{ assigns: assigns = %{ vas: vas } }, %{ "id" => id, "data" => data = %{ "type" => "ProductCollectionMembership" } }) do
    fields =
      Params.to_attributes(data)
      |> underscore_value(["kind", "name_sync"])

    request = %AccessRequest{
      vas: assigns[:vas],
      params: %{ id: id },
      fields: fields,
      preloads: assigns[:preloads],
      locale: assigns[:locale]
    }

    case Catalogue.update_product_collection_membership(request) do
      {:ok, %AccessResponse{ data: product_collection_membership }} ->
        render(conn, "show.json-api", data: product_collection_membership, opts: [include: conn.query_params["include"]])
      {:error, %AccessResponse{ errors: errors }} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: extract_errors(errors))
    end
  end

  def delete(conn = %{ assigns: assigns = %{ vas: vas } }, %{ "id" => id }) do
    request = %AccessRequest{
      vas: assigns[:vas],
      params: %{ id: id }
    }

    {:ok, _} = Catalogue.delete_product_collection_membership(request)

    send_resp(conn, :no_content, "")
  end

end
