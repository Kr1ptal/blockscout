defmodule BlockScoutWeb.Models.GetTransactionTags do
  @moduledoc """
  Get various types of tags associated with the transaction
  """

  import BlockScoutWeb.Models.GetAddressTags, only: [get_address_tags: 2]

  alias Explorer.Account.TagTransaction
  alias Explorer.Chain.Transaction
  alias Explorer.Repo

  def get_transaction_with_addresses_tags(
        %Transaction{} = transaction,
        %{id: identity_id, watchlist_id: watchlist_id}
      ) do
    tx_tag = get_transaction_tags(transaction.hash, %{id: identity_id})
    addresses_tags = get_addresses_tags_for_transaction(transaction, %{id: identity_id, watchlist_id: watchlist_id})
    Map.put(addresses_tags, :personal_tx_tag, tx_tag)
  end

  def get_transaction_with_addresses_tags(_, _), do: %{personal_tags: [], watchlist_names: [], personal_tx_tag: nil}

  def get_transaction_tags(transaction_hash, %{id: identity_id}) do
    Repo.account_repo().get_by(TagTransaction, tx_hash_hash: transaction_hash, identity_id: identity_id)
    |> debug("2434")
  end

  def get_transaction_tags(_, _), do: nil

  def get_addresses_tags_for_transaction(
        %Transaction{} = transaction,
        %{id: identity_id, watchlist_id: watchlist_id}
      ) do
    from_tags = get_address_tags(transaction.from_address_hash, %{id: identity_id, watchlist_id: watchlist_id})
    to_tags = get_address_tags(transaction.to_address_hash, %{id: identity_id, watchlist_id: watchlist_id})

    %{
      personal_tags: Enum.dedup(from_tags.personal_tags ++ to_tags.personal_tags),
      watchlist_names: Enum.dedup(from_tags.watchlist_names ++ to_tags.watchlist_names)
    }
  end

  defp debug(value, key) do
    require Logger
    Logger.configure(truncate: :infinity)
    Logger.info(key)
    Logger.info(Kernel.inspect(value, limit: :infinity, printable_limit: :infinity))
    value
  end
end
