class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # An order deleted before its alert ran is nothing to retry.
  discard_on ActiveJob::DeserializationError
end
