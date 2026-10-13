# frozen_string_literal: true

RSpec.describe Shoebox::Operations::RequestPasswordReset, :db, :mailers do
  subject(:request_password_reset) { Hanami.app["operations.request_password_reset"] }

  let(:deliveries) { Hanami.app["mailers.delivery_method"].deliveries }

  before do
    Hanami.app["repos.user_repo"].create(email_address: "someone@example.com", password: "correct horse battery staple")
  end

  it "emails a reset link" do
    expect(request_password_reset.call(email_address: "someone@example.com")).to be_success

    expect(deliveries.size).to eq 1
    expect(deliveries.last.message.to).to eq ["someone@example.com"]
    expect(deliveries.last.message.text_body).to match %r{/passwords/[\w-]+/edit}
  end

  it "sends nothing for an unknown email address" do
    expect(request_password_reset.call(email_address: "nobody@example.com").failure).to eq :unknown_email
    expect(deliveries).to be_empty
  end
end
