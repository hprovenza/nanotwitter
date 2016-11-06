#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require "zlib"
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

  #AWS keys for S3 image storage
  s3_bucket = ENV["AWS_BUCKET"]
  s3_key = ENV["AWS_ACCESS_KEY_ID"]
  s3_secret = ENV["AWS_SECRET_ACCESS_KEY"]
  s3_region = ENV['AWS_REGION']

end

configure :test do
  # allows excecuting unit tests from any directory
  erbname = File.join(__dir__, "database.yml")
  erbfile = ERB.new(File.read(erbname))
  erbfile.filename = erbname
  databases = YAML.load(erbfile.result)
  ActiveRecord::Base.establish_connection(databases['test'])
end
