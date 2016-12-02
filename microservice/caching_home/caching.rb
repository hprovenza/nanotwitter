# require "bunny"

class CacheConsumer

  def initialize rb_consumer_url
    @consumer = Bunny.new(rb_consumer_url)
    @consumer.start
    @channel = @consumer.create_channel
  end

  def declare_queue queue_name
    @q = @channel.queue("reptile_caching_service")
  end

  def receive
    @q.subscribe(:block => true) do |delivery_info, properties, body|

  	puts "Received #{body}"
    # should send body to redis here

    end
  end

end

cc = CacheConsumer.new ENV["RABBITMQ_BIGWIG_RX_URL"]
cc.declare_queue "reptile_caching_service"
puts "LISTENING TO QUEUE: reptile_caching_service"
cc.receive
