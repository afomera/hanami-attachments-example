# frozen_string_literal: true

RSpec.describe Shoebox::Operations::SignIn, :db do
  subject(:sign_in) { Hanami.app["operations.sign_in"] }

  let(:password) { "correct horse battery staple" }
  let!(:user) { Hanami.app["repos.user_repo"].create(email_address: "someone@example.com", password:) }

  it "returns the user for the right email address and password" do
    result = sign_in.call(email_address: " Someone@Example.com ", password:)

    expect(result.value!.id).to eq user.id
  end

  it "fails the same way for a wrong password and an unknown email address" do
    expect(sign_in.call(email_address: "someone@example.com", password: "wrong").failure).to eq :invalid_credentials
    expect(sign_in.call(email_address: "nobody@example.com", password:).failure).to eq :invalid_credentials
    expect(sign_in.call(email_address: "", password: "").failure).to eq :invalid_credentials
  end
end
