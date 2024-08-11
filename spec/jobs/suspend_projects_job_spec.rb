# frozen_string_literal: true

describe SuspendProjectsJob do
  include SpecTestHelper

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create!(name: 't', protocol: 'http', domain: 'test.co', free_clicks_threshold: 100) }
  let!(:article) do
    article = project.articles.create!(article_hash: '354', article: 'On the...')
    # call_id = article.summary_llm_calls.create!(llm: 'gpt-4o-mini', project:, input: 'A.', output: 'B.')
    # article.update!(summary_llm_call: call_id)
    article
  end
  let!(:page) do
    url = 'http://localhost:3000/how-to'
    # url_hash = Hashing.md5(url)
    url_hash = url
    project.pages.create!(url:, url_hash:, article:)
  end
  let(:time) { Time.now.utc }

  describe '#perform' do
    it 'does not suspend project' do
      ProjectStatistic.create!(project:, trackable: page, date: time.to_date, hour: time.hour, views: 999, clicks: 100)

      expect(project.status).to eq('active')
      expect do
        described_class.perform
      end.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('active')
      expect(project.plan).to eq('free')
    end

    it 'does not activate free plan when it is suspended' do
      project.statistics.create!(
        trackable: page,
        date: time.to_date,
        hour: time.hour,
        views: 10, clicks: rand(0..10)
      )
      project.update!(status: 'suspended')
      expect do
        described_class.perform
      end.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('suspended')
      expect(project.plan).to eq('free')
    end
    
    it 'suspends free plan project' do
      time = Time.now.utc
      project.statistics.create!(
        trackable: page,
        date: time.to_date,
        hour: time.hour,
        views: 999, clicks: 101
      )

      expect(project.status).to eq('active')
      expect do
        described_class.perform
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(project.reload.status).to eq('suspended')
      expect(project.plan).to eq('free')

      expect(ActionMailer::Base.deliveries.last.body.raw_source).to \
        include("Take a look what you’ve achieved with your free trial")
    end
    
    context 'when project has a light plan' do
      let!(:project) { user.projects.create!(name: 't', protocol: 'http', domain: 'test.co', plan: 'light') }

      it 'suspends light plan project' do
        project.statistics.create!(
          trackable: page,
          date: time.to_date,
          hour: time.hour,
          views: 9999, clicks: rand(5000..5001)
        )

        expect(project.status).to eq('active')
        expect do
          described_class.perform
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(project.reload.status).to eq('suspended')
        expect(project.plan).to eq('light')

        expect(ActionMailer::Base.deliveries.last.body.raw_source).to \
          include("The Light plan includes a 5,000 clicks limit.")
      end

      it 'activates pro plan when a new month begins' do
        project.statistics.create!(
          trackable: page,
          date: time.to_date,
          hour: time.hour,
          views: 99_999, clicks: rand(0..999)
        )
        project.update!(status: 'suspended')
        expect do
          described_class.perform
        end.not_to(change { ActionMailer::Base.deliveries.size })
        expect(project.reload.status).to eq('active')
        expect(project.plan).to eq('light')
      end
    end

    context 'when project has a pro plan' do
      let!(:project) { user.projects.create!(name: 't', protocol: 'http', domain: 'test.co', plan: 'pro') }

      it 'suspends pro plan project' do
        project.statistics.create!(
          trackable: page,
          date: time.to_date,
          hour: time.hour,
          views: 99_999, clicks: rand(25_000..25_001)
        )

        expect(project.status).to eq('active')
        expect do
          described_class.perform
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(project.reload.status).to eq('suspended')
        expect(project.plan).to eq('pro')

        expect(ActionMailer::Base.deliveries.last.body.raw_source).to \
          include("and has reached its Pro plan 25,000 clicks limit.")
      end

      it 'activates pro plan when a new month begins' do
        project.statistics.create!(
          trackable: page,
          date: time.to_date,
          hour: time.hour,
          views: 99_999, clicks: rand(0..999)
        )
        project.update!(status: 'suspended')
        expect do
          described_class.perform
        end.not_to(change { ActionMailer::Base.deliveries.size })
        expect(project.reload.status).to eq('active')
        expect(project.plan).to eq('pro')
      end
    end
  end
end
