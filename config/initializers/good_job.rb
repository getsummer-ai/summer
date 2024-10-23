
Rails.application.configure do
  config.good_job.max_threads = 1
  config.good_job.enable_cron = true
  config.good_job.cron = {
    close_replicate_requests: {
      cron: '0,30 * * * *',
      class: 'SuspendProjectsJob'
    },
    refresh_project_statistics_by_month: {
      cron: '*/10 * * * *',
      class: 'RefreshProjectStatisticsByMonthJob'
    }
  }
end
