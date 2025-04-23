class ScheduleProductCreationJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      ProductCreationWorker.perform_async(user.id)
    end
  end
end
