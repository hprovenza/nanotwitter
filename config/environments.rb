#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require "zlib"
require "redis"
require "bunny"

configure do
  #AWS keys for S3 image storage
  s3_bucket = ENV["aws_s3_bucket"]
  s3_key = ENV["aws_s3_key"]
  s3_secret = ENV["aws_s3_secret"]

  #Redis
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])
end

configure :production, :development do
  require 'newrelic_rpm'
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/ntdb')

  ActiveRecord::Base.establish_connection(
      :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
  )
end

configure :test do
  # allows excecuting unit tests from any directory
  erbname = File.join(__dir__, "database.yml")
  erbfile = ERB.new(File.read(erbname))
  erbfile.filename = erbname
  databases = YAML.load(erbfile.result)
  ActiveRecord::Base.establish_connection(databases['test'])
end
