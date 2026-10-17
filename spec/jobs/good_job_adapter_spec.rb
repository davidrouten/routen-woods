require "rails_helper"

# The point of GoodJob: an enqueued job is a database row, so it survives a
# dyno restart instead of living in process memory like the :async adapter.
RSpec.describe "GoodJob adapter" do
  around do |example|
    original = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = GoodJob::Adapter.new(execution_mode: :external)
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original
  end

  it "persists enqueued jobs to Postgres" do
    inbound_lead = create(:inbound_lead)

    expect { ProcessInboundLeadJob.perform_later(inbound_lead) }
      .to change(GoodJob::Job, :count).by(1)

    job = GoodJob::Job.last
    expect(job.job_class).to eq("ProcessInboundLeadJob")
    expect(job.finished_at).to be_nil
  end
end
