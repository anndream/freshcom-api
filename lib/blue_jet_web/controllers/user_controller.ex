defmodule BlueJetWeb.UserController do
  use BlueJetWeb, :controller

  alias BlueJet.Identity.User
  alias BlueJet.Identity
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json-api", data: users)
  end

  def create(conn, %{"data" => data = %{"type" => "User", "attributes" => _user_params}}) do
    with {:ok, user} <- Identity.create_user(%{ fields: Params.to_attributes(data) }) do
      conn
      |> put_status(:created)
      |> render("show.json-api", data: user)
    else
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: extract_errors(changeset))
    end
  end

  def show(conn = %{ assigns: assigns = %{ vas: %{ account_id: _, user_id: user_id } } }, _) do
    request = %{
      vas: assigns[:vas],
      user_id: user_id,
      preloads: assigns[:preloads],
      locale: assigns[:locale]
    }

    user = Identity.get_user!(request)

    render(conn, "show.json-api", data: user, opts: [include: conn.query_params["include"]])
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "user", "attributes" => _user_params}}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

end