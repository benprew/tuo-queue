# parses a job result for easy display
require_relative 'tuo_queue'

class Result
  attr_reader :enqueue_time, :user, :cmd, :output

  def initialize(result_file)
    file = "#{TuoQueue::COMPLETED_DIR}/#{result_file}"
    (@enqueue_time, @user) = result_file.split(/_/)
    (@cmd, @output) = File.read(file).split("\n")
  end
end
