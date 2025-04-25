Sidekiq::Cron::Job.create(
  name: 'Schedule product creation every 5 minutes',
  cron: '* * * * *',
  class: 'ScheduleProductCreationJob'
)
