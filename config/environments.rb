#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require "zlib"
configure :production, :development do
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
  databases = YAML.load_file("config/database.yml")
  ActiveRecord::Base.establish_connection(databases['test'])
end
