# Shoebox

An example Hanami app (built on Hanami's main branches) for
[hanami-attachments](../hanami-attachments). Each user keeps photos with thumbnails, a profile
avatar, and video clips uploaded directly from the browser.

## Commits

The first commits are pure generator output, so each diff shows exactly what a command wrote:

1. `hanami new shoebox --head`, then hanami-attachments, hanami-auth and hanami-turbo added.
2. `hanami generate auth`
3. `hanami generate storage`
4. `hanami generate attachment user avatar`: images, with a 300px thumbnail.
5. `hanami generate attachment clip video --types=video`: up to 2 GB, uploaded directly.
6. `hanami generate attachment photo image`: creates the `photos` table too.

The hand-written part comes after that: owners and titles, the photo grid, the profile page, the
clip upload with a progress bar, and the player.

## Running it

```
bundle install && npm install
bundle exec hanami db prepare && bundle exec hanami db seed
bundle exec hanami assets compile
bundle exec hanami server
```

Sign in as demo@example.com with the password "shoebox demo password".

Files are stored in `storage/` in development and in memory in tests. To try S3, set the
`STORAGE_*` variables described in `.env`, for example in `.env.development.local`.

```
bundle exec rspec
```
