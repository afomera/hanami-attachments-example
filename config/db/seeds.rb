# frozen_string_literal: true

# A demo account: demo@example.com / "shoebox demo password"
user_repo = Hanami.app["repos.user_repo"]
user_repo.find_by_email("demo@example.com") ||
  user_repo.create(email_address: "demo@example.com", password: "shoebox demo password")
