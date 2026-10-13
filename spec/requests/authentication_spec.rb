# frozen_string_literal: true

RSpec.describe "Authentication", :db, :mailers, type: :request do
  let(:user_repo) { Hanami.app["repos.user_repo"] }
  let(:deliveries) { Hanami.app["mailers.delivery_method"].deliveries }
  let(:password) { "correct horse battery staple" }
  let!(:user) { user_repo.create(email_address: "Someone@Example.com ", password:) }

  def signed_in?
    get "/session/new"
    last_response.status == 302
  end

  it "signs in with the right email and password" do
    sign_in_as(user, password:)

    expect(last_response.status).to eq 303
    expect(last_response.location).to eq "/"
    expect(signed_in?).to be true
  end

  it "rejects the wrong password without revealing whether the account exists" do
    sign_in_as(user, password: "wrong password")
    wrong_password = last_response

    sign_in_as(double(email_address: "nobody@example.com"), password:)

    expect(wrong_password.status).to eq 422
    expect(last_response.status).to eq 422
    expect(last_response.body).to include "Try another email address or password."
    expect(signed_in?).to be false
  end

  it "requires a signed-in user for protected actions" do
    delete "/session"

    expect(last_response.status).to eq 303
    expect(last_response.location).to eq "/session/new"
  end

  it "signs out" do
    sign_in_as(user, password:)
    delete "/session"

    expect(last_response.status).to eq 303
    expect(signed_in?).to be false
  end

  it "resets the password with an emailed link, which works only once" do
    post "/passwords", email_address: "someone@example.com"

    expect(last_response.status).to eq 303
    expect(deliveries.size).to eq 1

    reset_path = URI(deliveries.last.message.text_body[%r{https?://\S+}]).path
    get reset_path
    expect(last_response.status).to eq 200

    patch reset_path.delete_suffix("/edit"), password: "a brand new password", password_confirmation: "a brand new password"
    expect(last_response.status).to eq 303

    sign_in_as(user, password: "a brand new password")
    expect(signed_in?).to be true

    get reset_path
    expect(last_response.status).to eq 302
  end

  it "doesn't send email for unknown addresses" do
    post "/passwords", email_address: "nobody@example.com"

    expect(last_response.status).to eq 303
    expect(deliveries).to be_empty
  end
end
