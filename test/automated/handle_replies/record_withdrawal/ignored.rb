require_relative '../../automated_init'

context "Handle Replies" do
  context "Record Withdrawal" do
    context "Ignored" do
      handler = Handlers::Replies.new

      record_withdrawal = Account::Client::Controls::Replies::RecordWithdrawal.example

      funds_transfer_id = Controls::FundsTransfer.id
      funds_transfer_command_stream_name = "fundsTransfer:command-#{funds_transfer_id}"
      record_withdrawal.metadata.source_message_stream_name = funds_transfer_command_stream_name

      funds_transfer = Controls::FundsTransfer.example
      assert(funds_transfer.withdrawn?)

      handler.store.add(funds_transfer.id, funds_transfer)

      handler.(record_withdrawal)

      writer = handler.write

      withdrawn = writer.one_message do |event|
        event.instance_of?(Messages::Events::Withdrawn)
      end

      test "Withdrawn event is not written" do
        assert(withdrawn.nil?)
      end
    end
  end
end




#       funds_transfer_id = Controls::FundsTransfer.id
#       funds_transfer_command_stream_name = "fundsTransfer:command-#{funds_transfer_id}"
#       record_withdrawal.metadata.source_message_stream_name = funds_transfer_command_stream_name

#       withdrawal_id = record_withdrawal.withdrawal_id or fail
#       account_id = record_withdrawal.account_id or fail
#       amount = record_withdrawal.amount or fail
#       effective_time = record_withdrawal.time or fail

#       funds_transfer_stream_name = "fundsTransfer-#{funds_transfer_id}"

#       handler.(record_withdrawal)

#       writer = handler.write

#       withdrawn = writer.one_message do |event|
#         event.instance_of?(Messages::Events::Withdrawn)
#       end

#       test "Initiated event is written" do
#         refute(withdrawn.nil?)
#       end

#       test "Written to the funds transfer stream" do
#         written_to_stream = writer.written?(withdrawn) do |stream_name|
#           stream_name == funds_transfer_stream_name
#         end

#         assert(written_to_stream)
#       end

#       context "Attributes" do
#         test "funds_transfer_id" do
#           assert(withdrawn.funds_transfer_id == funds_transfer_id)
#         end

#         test "account_id" do
#           assert(withdrawn.account_id == account_id)
#         end

#         test "amount" do
#           assert(withdrawn.amount == amount)
#         end

#         test "time" do
#           assert(withdrawn.time == effective_time)
#         end

#         test "processed_time" do
#           processed_time_iso8601 = Clock.iso8601(processed_time)

#           assert(withdrawn.processed_time == processed_time_iso8601)
#         end
#       end
#     end
#   end
# end
