require 'json'
require 'bundler'
require 'sequel'
require 'sqlite3'

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
  TUO_DIR='/var/local/tuo-queue/tuo'

  attr_reader :queue_time, :job_id

  def perform
    if self.completed_at
      warn 'job already completed, skipping'
      return
    end

    job_cmd = "cd #{TUO_DIR} && ./tuo #{command} 2>&1"
    warn job_cmd
    output = `#{job_cmd} 2>/tmp/#{job_id}.log`
    warn output

    self.output = output
    self.completed_at = Time.now
    save
  end

  def self.completed
    Job.exclude(completed_at: nil).reverse_order(:created_at)
  end

  def self.list
    Job.reverse_order(:created_at)
  end

  def self.queued
    Job.where(completed_at: nil).reverse_order(:created_at)
  end
end
