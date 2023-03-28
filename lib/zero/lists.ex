defmodule Zero.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.Query, warn: false
  alias Zero.Repo

  alias Zero.Lists.Card

  defp list_cards do
    query =
      from c in Card,
        order_by: [asc: c.inserted_at]

    Repo.all(query)
  end

  @doc """
  Returns the list of cards, unless it's passed ""
  Then it retruns an empty list.

  ## Examples

  iex> list_cards("Edgar")
  [%Card{}, ...]

  """
  def list_cards(editor) do
    if editor == "" do
      []
    else
      list_cards()
    end
  end

  @doc """
  Returns the list of cards, unless it's passed ""
  Then it retruns an empty list.
  Filters that list by creator.

  ## Examples

  iex> list_cards("Edgar", "Edgar")
  [%Card{}, ...]

  """
  def list_cards(creator, editor) do
    if editor == "" do
      []
    else
      query =
        from c in Card,
          where: like(c.creators, ^"%#{creator}%"),
          order_by: [asc: c.inserted_at]

      Repo.all(query)
    end
  end

  @doc """
  Returns only unfinished cards
  Otherwise should behave like list_cards/2
  """

  def list_unfinished_cards(creator, editor) do
    if editor == "" do
      []
    else
      query =
        from c in Card,
        where: c.finished == false,
        where: like(c.creators, ^"%#{creator}%"),
        order_by: [asc: c.inserted_at]

      Repo.all(query)
    end
  end

  @doc """
  Gets a single card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(%{field: value})
      {:ok, %Card{}}

      iex> create_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(card, %{field: new_value})
      {:ok, %Card{}}

      iex> update_card(card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a card.

  ## Examples

      iex> delete_card(card)
      {:ok, %Card{}}

      iex> delete_card(card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card changes.

  ## Examples

      iex> change_card(card)
      %Ecto.Changeset{data: %Card{}}

  """
  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end
end
