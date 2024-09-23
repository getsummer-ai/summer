# frozen_string_literal: true
#
class ProjectStripeService
  class Plan
    # There is a problem with subscription logic which I'm not going to solve right now.
    #
    # The problem is following:
    #
    # When a user changes interval of subscription from month to year or vice versa -
    # a new project_subscription row is created so the limit of usage is reset.
    #
    # Foe example.
    # Somebody paid 90$ for 60_000 clicks per year. He had spent 60_000 clicks in first month and decided to
    # change Stripe interval to the monthly. -> He will have 5_000 clicks per month and will be paying
    # nothing for the next 11 months.
    # If the user reaches the limit of 5_000 clicks in the first month,
    # his project will be suspended, and the user will be able to change interval to yearly again,
    # and he will get 60_000 clicks for the next 12 months again. In total he will pay only 90$ + (90/12)$
    #
    PLAN_IDS = {
      test: {
        light: {
          year: 'price_1PBXGeDm8NzUNvXDPM4V1dha',
          month: 'price_1PBXHIDm8NzUNvXDFmCw828n',
        },
        pro: {
          year: 'price_1PBXI6Dm8NzUNvXDk0FfLVtH',
          month: 'price_1PBXORDm8NzUNvXDoV7gv6Zi',
        },
      },
      live: {
        light: {
          year: 'price_1PFK07Dm8NzUNvXDBJER9D7s',
          month: 'price_1PFJzGDm8NzUNvXDrUfab0EI',
        },
        pro: {
          year: 'price_1PFK16Dm8NzUNvXDZcLnQSWa',
          month: 'price_1PFK0dDm8NzUNvXDsMXEPJ9s',
        },
      },
    }.freeze

    PLAN_LIMITS = {
      light: {
        month: 5_000,
        year: 60_000,
      },
      pro: {
        month: 25_000,
        year: 300_000,
      },
    }.freeze

    # @return [String]
    attr_reader :stripe_plan_id

    # @return [Symbol]
    attr_reader :name

    # @return [Symbol]
    attr_reader :interval

    # @param stripe_plan_id [String]
    # @param name [Symbol]
    # @param interval [Symbol]
    def initialize(stripe_plan_id, name, interval)
      @stripe_plan_id = stripe_plan_id
      @name = name
      @interval = interval
    end

    def summarize_limit
      PLAN_LIMITS[name][interval] || 0
    end


    # @param [Stripe::Plan] plan
    # @return [ProjectStripeService::Plan, nil]
    def self.find_by_stripe_plan(plan)
      env_plans = PLAN_IDS[plan.livemode == true ? :live : :test]
      interval = plan.interval.to_sym
      plan_name = nil
      plan_name = :light if env_plans.dig(:light, interval) == plan.id
      plan_name = :pro if env_plans.dig(:pro, interval) == plan.id
      return new(plan.id, plan_name, interval) if plan_name.present?

      nil
    end
  end
end
