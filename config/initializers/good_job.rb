
Rails.application.configure do
  config.good_job.max_threads = 1
  config.good_job.enable_cron = true
  config.good_job.cron = {
    close_replicate_requests: {
      cron: '*/10 * * * *',
      class: 'SuspendProjectsJob'
    }
  }
end
