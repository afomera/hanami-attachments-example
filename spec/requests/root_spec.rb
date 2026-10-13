# frozen_string_literal: true

RSpec.describe "Root", type: :request do
  it "sends signed-out visitors to sign in" do
    get "/"

    expect(last_response.status).to eq 302
    expect(last_response.headers["location"]).to end_with "/session/new"
  end
end
