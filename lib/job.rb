class Job
  attr_reader :queue_time

  def initialize(file)
    @file = file
    (@queue_time, @user) = file.split(/_/)
  end

  def command
    File.read("#{TuoQueue::QUEUE_DIR}/#{@file}")
  end
end
