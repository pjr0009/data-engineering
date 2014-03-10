# Phillip Robertson's Software Engineer - Big Data submission

Prerequisites:  Ruby version >= 1.9.3, Rails 4.


1) clone repo
2) install postgres and redis.
3) start up redis: "redis-server"
4) bundle install
5) bundle exec rake db:setup
6) bundle exec rake db:test:prepare
7) bundle exec rails s


#About this project
The project uses Devise for authentication, so you will need to sign up using some email+pw combination in order to upload reports for processing. Once you register, you may upload any valid tab-seperated file for processing. After it is processed you may view uploaded reports, their total values, and also a detailed table of entries for each report.

#performance
due to queueing with redis and delayed job, the immediate total is available quickly, but the detailed view may take up to 30 seconds to process. I've currently benchmarked the app up 50,000 rows. It could easily exceed that, but I would have to upgrade my postgres and redis instances past the free tier on heroku.

#How processing is done
- file is uploaded
- Ruby's CSV class is used to parse each row.
- The total is calculated.
- Rows are temporarily pipelined into redis.
- A delayed job is created to asynchronously normalize the data in the background.
- The data is completely normalized and put into postgres (see section below on structure for details).
- Redis keys are expired once the delayed job completes.

#structure/data
I normalized it from the perspective of how I think Living Social would want the data organized. One business (e.g. Etsy) has many merchants (e.g. various independent merchants). Those merchants have many customers and deals. This would allow a business, or the merchants in their network, view all of their customers, purchases, and deals (as well as various combinations of that data to help them improve their marketing strategies).

#Running tests
```ruby
bundle exec rspec
```
