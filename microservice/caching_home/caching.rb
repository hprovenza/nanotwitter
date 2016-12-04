require "bunny"
require_relative "../../app"
require_relative "./cache_helper"
include CacheHelper

class CacheConsumer

  def initialize rb_consumer_url
    @consumer = Bunny.new(rb_consumer_url)
    @consumer.start
    @channel = @consumer.create_channel
  end

  def declare_queue queue_name
    @q = @channel.queue("reptile_caching_service")
  end

  def consume
    @q.subscribe(:block => true) do |delivery_info, properties, body|

  	puts "Received #{body}"

    u_id, t_id = body.split "-|SEP|-"
    @user = User.find(u_id)
    t = Tweet.find(t_id)

    update_recent(@user, t)
    cache_index_page
    update_follower_timelines(@user, t)
    cache_follower_homepages(@user)
    end
  end

end

cc = CacheConsumer.new ENV["RABBITMQ_BIGWIG_RX_URL"]
cc.declare_queue "reptile_caching_service"
puts "LISTENING TO QUEUE: reptile_caching_service"
cc.consume
