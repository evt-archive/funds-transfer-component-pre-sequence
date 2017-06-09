require_relative '../../automated_init'

context "Handle Replies" do
  context "Record Withdrawal" do
    context "Expected Version" do
      handler = Handlers::Replies.new

      record_withdrawal = Account::Client::Controls::Replies::RecordWithdrawal.example

      funds_transfer_id = Controls::FundsTransfer.id
      funds_transfer_command_stream_name = "fundsTransfer:command-#{funds_transfer_id}"
      record_withdrawal.metadata.source_message_stream_name = funds_transfer_command_stream_name

      funds_transfer = Controls::FundsTransfer::Initiated.example
      refute(funds_transfer.withdrawn?)

      version = Controls::Version.example

      handler.store.add(funds_transfer_id, funds_transfer, version)

      handler.(record_withdrawal)

      writer = handler.write

      withdrawn = writer.one_message do |event|
        event.instance_of?(Messages::Events::Withdrawn)
      end

      test "Is entity version" do
        written_to_stream = writer.written?(withdrawn) do |_, expected_version|
          expected_version == version
        end

        assert(written_to_stream)
      end
    end
  end
end
