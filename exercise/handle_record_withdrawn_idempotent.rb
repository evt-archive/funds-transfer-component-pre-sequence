require_relative 'exercise_init'

funds_transfer_id = Identifier::UUID::Random.get

record_withdrawal = Account::Client::Messages::Replies::RecordWithdrawal.new

funds_transfer_command_stream_name = "fundsTransfer:command-#{funds_transfer_id}"
record_withdrawal.metadata.source_message_stream_name = funds_transfer_command_stream_name

record_withdrawal.withdrawal_id = Identifier::UUID::Random.get
record_withdrawal.account_id = Identifier::UUID::Random.get
record_withdrawal.amount = 11
record_withdrawal.time = '2000-01-01T11:11:11.000Z'
record_withdrawal.processed_time = '2000-01-01T22:22:22.000Z'

pp record_withdrawal

2.times do
  Messaging::Postgres::Write.(record_withdrawal, funds_transfer_command_stream_name)
end

MessageStore::Postgres::Read.(funds_transfer_command_stream_name) do |message_data|
  Handlers::Replies.(message_data)
  pp message_data
end
