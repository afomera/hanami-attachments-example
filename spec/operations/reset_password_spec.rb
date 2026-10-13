# frozen_string_literal: true

RSpec.describe Shoebox::Operations::ResetPassword, :db do
  subject(:reset_password) { Hanami.app["operations.reset_password"] }

  let(:user_repo) { Hanami.app["repos.user_repo"] }
  let(:tokens) { Hanami.app["authentication.password_reset_tokens"] }
  let(:new_password) { "a brand new password" }
  let!(:user) { user_repo.create(email_address: "someone@example.com", password: "correct horse battery staple") }

  it "sets the new password and signs the user out everywhere" do
    Hanami.app["repos.session_repo"].create(user_id: user.id, token_digest: "digest")

    result = reset_password.call(token: tokens.generate(user), password: new_password, password_confirmation: new_password)

    expect(result).to be_success
    expect(Hanami.app["operations.sign_in"].call(email_address: "someone@example.com", password: new_password)).to be_success
    expect(Hanami.app["relations.sessions"].where(user_id: user.id).count).to eq 0
  end

  it "accepts a token only once" do
    token = tokens.generate(user)
    reset_password.call(token:, password: new_password, password_confirmation: new_password)

    result = reset_password.call(token:, password: "another new password", password_confirmation: "another new password")

    expect(result.failure).to eq :invalid_token
  end

  it "rejects an expired token" do
    token = tokens.generate(user, now: Time.now - (16 * 60))

    expect(reset_password.call(token:, password: new_password, password_confirmation: new_password).failure).to eq :invalid_token
  end

  it "rejects a short or mismatched password" do
    token = tokens.generate(user)

    expect(reset_password.call(token:, password: "short", password_confirmation: "short").failure)
      .to eq [:invalid_password, "Password must be at least 12 characters."]
    expect(reset_password.call(token:, password: new_password, password_confirmation: "something else").failure)
      .to eq [:invalid_password, "Passwords don't match."]
  end
end
