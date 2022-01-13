# DoneDesk

[![Codeship Status for GrokInteractive/donedesk](https://app.codeship.com/projects/ff3b6ed0-e56d-0134-a2bf-021adfcc097e/status?branch=master)](https://app.codeship.com/projects/206525)

The application is currently hosted on Heroku with plans to migrate fully to AWS. All user uploaded files (PDFs, videos, etc.) are stored on [AWS S3](https://aws.amazon.com/s3/). Sensitive environment config values are stored in [AWS KMS](https://aws.amazon.com/kms/), separate from non-sensitive environment config, which are stored in both Heroku's env config vars and environment-specific dot env files, e.g. `.env.test`, `.env.development`, `.env.app-staging.donedesk.com`, `.env.app.donedesk.com`.

One pain point within the application is the concept of "Canned" vs "Custom". "Canned" meaning built-in and not belonging to a specific Account; can only be managed by the Super Admin. "Custom", meaning belonging to and manageable by a specific Account. There are currently 3 models used in this way: Courses, Document Types and Library Documents. An `account_id` field is used to distinguish canned from custom. If `account_id` is `nil`, then it's a canned item, if an `account_id` is present, it's a custom item. This design resulted in some awkward queries and is a bit confusing in the UI (especially to the super admin).

The main layers of the application consist of:

 - **Presenters** - handle presentation of the model data
 - **Forms** - handle user input validation and some presentation
 - **Queries** - handle retrieving of data
 - **Models** - mainly Active Record models but also some POROs
 - **Commands** - handle update/create, sending emails, 3rd-party calls, etc.
 - **Policies** - handle access control

Here's an example application flow:

 1. User visits `/courses/new`
 2. Controller calls into `CoursePolicy` to authorize request and creates an instance of `CourseForm` to pass to the ERB template
 3. User fills in and submits the form
 4. Controller calls into `CoursePolicy` to authorize request, creates an instance of `CourseForm` from the `params` and then passes the instance of `CourseForm` to the `CreateCourse` command
 6. `CreateCourse` uses the `CourseForm` attributes to create a new `Course` and executes any additional business logic
 7. Controller redirects or renders based the result of the `CreateCourse` command

It's possible that Presenters do not exist for all models. This was a WIP refactoring and should be continued. If you need to edit an ERB template that is not backed by a Presenter yet, and you have the time, definitely introduce a new Presenter.

There are also some inconsistent redirect/render code within controllers, which was also part of a WIP refactoring. Any render/redirect code you come across, that does not look like the following, can be updated to use the following helpers:
```ruby
CreateCourse.call(@form) do
  on(:ok)      { |course| set_flash_success_and_redirect_to(course) }
  on(:invalid) { set_flash_error_and_render(:new) }
end
```

## WIP Refactorings

### Inherited default permissions from `ApplicationPolicy` for policy objects

Initially it seemed like a good idea to have each policy object inherit a set of default permissions for each action to reduce duplication. However, over time, it became clear that being explicit about permissions, even when it means duplication, is better than being implicit.

Proposed solution:

Raise a "Not implemented" error for the actions that are not implemented. That way permissions for every resource are VERY clear.

## Development

### Setup


Copy the AWS Credentials file and supply with your own credentials

```bash
cp .aws-credentials.dist .aws-credentials
```

Install gem dependencies and create/migrate the database:

```bash
bundle install
RAILS_ENV=development rails db:create
RAILS_ENV=development rails db:migrate
RAILS_ENV=test bin/rails db:migrate
```

Install necessary web driver dependencies for tests:

```bash
brew install phantomjs
brew cask install chromedriver
```

If not already installed, install Redis (for Sidekiq):

```bash
brew install redis
```

To load or reload test data (don't forget to stop the rails server, if running):

```bash
RAILS_ENV=development rails donedesk:db:populate
RAILS_ENV=development rails donedesk:db:repopulate
```

Start the Redis server, Sidekiq and Rails:
```bash
redis-server
bundle exec sidekiq -q default -q mailers
rails s
```

Visit [http://localhost:3000]().

See `test/support/test_password_helper.rb` for user auth credentials. You can sign in with a user of each role type:

 - super_admin@example.com
 - account_owner@example.com
 - account_manager@example.com
 - employee@example.com

All of these users belong to the Oceanview Dental account (defined in fixtures).

### Tests

http://blog.bigbinary.com/2016/01/03/test-runner-in-rails-5.html

Controller tests make up largest part of the test suite. In most cases, we test Account Owner, Account Manager and Employee roles, skipping the Super Admin role as a trade-off to save on overall test run time. In some cases, we only test the Account Manager and Employee, skipping the Account Owner, for the same reason (overall test suite run time) and because usually the Owner's permissions are the same as the Manager. However, overtime I realized that it's best to test both the Owner and the Manager.

Anything that's missing a unit test is usually intentional because the controller test provides adequate coverage. If testing multiple code paths through the controller becomes tedius or repetitive, I usually end up writing a unit test or functional test at a level closer to the actual function.

#### Running

```bash
# all EXCEPT acceptance
bin/rails test:skip_acceptance

# all tests
bin/rails t

# single directory
bin/rails t test/acceptance

# single file
bin/rails t test/models/user_test.rb

# single test
bin/rails t test/models/user_test.rb:27
```

#### Failing Tests? / Debugging

Capybara has a default wait time of 2 seconds, this may not be enough for some systems. If acceptance tests are failing, you can set a local environment variable to bump up the wait time: `export CAPYBARA_DEFAULT_MAX_WAIT_TIME=5`.

For debugging acceptance test failures, use `save_and_open_page` anywhere within the failing test. This will launch a browser and allow you to view the actual page and source.

### Notes

* If you're getting errors about undefined constants or just seemingly unrelated errors, try stopping spring: `spring stop`
* Based on how we're handling env vars, you may need to specify `RAILS_ENV=development` for some commands
* Assets don't seem to precompile automatically in development anymore, so you have to `rails assets:precompile RAILS_ENV=development` and then restart Rails, if you change any assets
* Controller tests are at the heart of the test suite and should pretty well cover most of the application. Acceptance tests, with mostly happy paths, also exist to exercise the full stack and some important JS pieces, for example account registration. There are likely a few areas of the application that are missing acceptance test coverage.
* The fixture data is based on two Accounts: Oceanview Dental and Brookside Dental. Oceaview and its related data is typically used in the context of being the "current account" when testing and Brookside is typically used as "another account". This is mainly for testing permissions scenarios, for example: "An Oceanview user should not be able to view or edit data belonging to another account (Brookside)".

### Emails

Use Mailcatcher to test sending of emails during development. Docs can be found here: https://mailcatcher.me/.

It's recommended that mailcatcher be installed without Bundler, so you won't find the dependency in our Gemfile.

#### Quick Steps:

1. `gem install mailcatcher`
1. `mailcatcher`
1. Go to http://localhost:1080/

### Test Data

To backup and restore data from production to your local dev database:

1. Capture a fresh backup:
```
heroku pg:backups capture --app donedesk-production
```

2. Download the backup. Note, you'll need the backup id from the previous command, e.g. `b007`:
```
wget -O production.dump `heroku pg:backups public-url <backup-id> --app donedesk-production`
```

3. Restore the backup:
```
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d donedesk-development production.dump
```

## Staging

Secured by basic HTTP Auth. Execute `heroku run rails secrets:fetch --app donedesk-staging` for credentials.

https://app-staging.donedesk.com/

To reset then populate DB for staging:

```bash
heroku pg:reset DATABASE --app donedesk-staging
heroku run rails db:migrate --app donedesk-staging
heroku run rails donedesk:db:populate --app donedesk-staging
```

On Heroku, to create an SSH-based terminal session into a dyno:
```
heroku ps:exec --app donedesk-staging
```

## Production

https://app.donedesk.com/

On Heroku, to create an SSH-based terminal session into a dyno:
```
heroku ps:exec --app donedesk-production
```

### Setup

Load ancillary data with:

```bash
rails db:seed
```

## AWS

We currently only use AWS for S3 and KMS services. The application itself is still hosted on Heroku. Hosting it on AWS is currently a work-in-progress.

### IAM

KMS
IAM Role
IAM User

### Secrets

To set a secret, simply use the following rake task:

```bash
RAILS_ENV=test rails secrets:set[key,value]
```

To view a list of secrets for an environment:

```bash
RAILS_ENV=development rails secrets:fetch
```

docker exec -it bfb62f03efbb authorize-certificates
docker exec -it 062f52229c55 fetch-and-link-certificates
docker restart 062f52229c55 -t 0


donedeskroot

create role donedesk login password 'pseudo-random-123';
grant all privileges on database donedesk to donedesk;
create extension "uuid-ossp";


## Deploy

[donedesk-deployer]
