class TuoQueue
  TUO_DIR = '/var/local/tuo-queue/tuo'
  QUEUE_DIR = '/var/local/tuo-queue/queued'
  COMPLETED_DIR = '/var/local/tuo-queue/finished'

  def self.completed
    Dir.glob("#{COMPLETED_DIR}/*.job").map { |f| File.basename f }.reverse
  end

  def self.enqueued
    Dir.glob("#{QUEUE_DIR}/*.job").map { |f| File.basename f }.reverse
  end

  def self.process(job)
    job_filename = "#{QUEUE_DIR}/#{job}"
    completed_file = "#{COMPLETED_DIR}/#{job}"
    job_cmd = File.read(job_filename)
    cmd = "cd #{TUO_DIR} && ./tuo #{job_cmd} 2>&1"
    warn cmd

    FileUtils.mkdir_p COMPLETED_DIR
    File.open(completed_file, 'w') do |f|
      f.write(job_cmd)
      output = `#{cmd}`
      warn "output: #{output}"
      f.write(output)
      f.write($!) if $? == 0
    end

    File.delete(job_filename)
  end
end
