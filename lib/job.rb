require 'json'
require 'bundler'
require 'sequel'
require 'sqlite3'

TUO_DIR='/var/local/tuo-queue/tuo'

# TODO: convert to sqllite-backed store.
DB = Sequel.sqlite('/var/local/tuo-queue/job.sqlite3')

DB.create_table? :jobs do
  primary_key :id
  String :name
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
  end

  def self.completed
    Job.exclude(completed_at: nil)
  end

  def self.queued
    Job.where(completed_at: nil)
  end
end
