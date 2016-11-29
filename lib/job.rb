require 'json'
require 'bundler'
require 'sequel'
require 'sqlite3'

# TODO: convert to sqllite-backed store.
DB = Sequel.sqlite('/var/local/tuo-queue/job.sqlite3')

DB.create_table? :jobs do
  primary_key :id
  String :command
  String :output
  String :user
  Time :created_at
  Time :completed_at
end

class Job < Sequel::Model
  attr_reader :queue_time, :job_id

  def perform
    if self.completed_at
      warn 'job already completed, skipping'
      return
    end

    job_cmd = "cd #{TUO_DIR} && ./tuo #{command} 2>&1"
    warn job_cmd

    self.output = `#{job_cmd}`
    self.completed_at = Time.now
    save

    queued_job && queued_job.delete
  end

  def self.completed
    Job.exclude(completed_at: nil)
  end

  def self.queued
    Job.where(completed_at: nil)
  end
end
