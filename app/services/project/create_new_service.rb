# frozen_string_literal: true
class Project
  class CreateNewService
    # @param [User] user
    # @param [Hash, ActionController::Parameters] params
    def initialize(user, params = {})
      @user = user
      @params = params
    end

    def create(log_source: nil)
      model = generate_new_project
      model.start_tracking(source: log_source, author: @user) if log_source.present?

      if model.valid?
        Project.transaction do
          model.save!(validate: false)
          subscription = create_free_subscription_for_project! model
          # set the free subscription to the project as the default subscription
          model.update!(subscription:)
        end
      end

      model
    end

    private

    # @return [Project]
    def generate_new_project
      Project.new(
        user_id: @user.id,
        name: @params[:name],
        protocol: @params[:protocol].presence || 'https',
        domain: @params[:domain],
        domain_alias: @params[:domain_alias].presence || nil,
        default_llm: 'gpt-4o',
        paths: @params[:paths].presence || ['/'],
      )
    end

    # @param [Project] model
    def create_free_subscription_for_project!(model)
      model.subscriptions.create!(
        plan: 'free',
        start_at: model.created_at,
        end_at: '2038-01-01 00:00:00',
        summarize_usage: 0,
        summarize_limit: ENV.fetch('FREE_PLAN_CLICKS_THRESHOLD', 100).to_i,
      )
    end
  end
end
