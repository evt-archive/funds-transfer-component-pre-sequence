module FundsTransferComponent
  module Handlers
    class Replies
      include Log::Dependency
      include Messaging::Handle
      include Messaging::StreamName
      include Messages::Events
      include Account::Client::Messages::Replies

      dependency :write, Messaging::Postgres::Write
      dependency :clock, Clock::UTC
      dependency :store, Store
      dependency :identifier, Identifier::UUID::Random

      def configure
        Messaging::Postgres::Write.configure(self)
        Clock::UTC.configure(self)
        Store.configure(self)
        Identifier::UUID::Random.configure(self)
      end

      category :funds_transfer

      handle RecordWithdrawal do |record_withdrawal|
        source_message_stream_name = record_withdrawal.metadata.source_message_stream_name
        funds_transfer_id = Messaging::StreamName.get_id(source_message_stream_name)

        funds_transfer, version = store.fetch(funds_transfer_id, include: :version)

        if funds_transfer.withdrawn?
          logger.info(tag: :ignored) { "Command ignored (Command: #{record_withdrawal.message_type}, Funds Transfer ID: #{funds_transfer_id}, Withdrawal Account ID: #{record_withdrawal.account_id})" }
          return
        end

        withdrawn = Withdrawn.follow(record_withdrawal)

        withdrawn.funds_transfer_id = funds_transfer_id

        withdrawn.processed_time = clock.iso8601

        stream_name = stream_name(funds_transfer_id)

        write.(withdrawn, stream_name, expected_version: version)
      end
    end
  end
end
