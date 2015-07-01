class Toxiproxy
  def self.running?
    TCPSocket.new('127.0.0.1', 8474).close
    true
  rescue Errno::ECONNREFUSED, Errno::ECONNRESET
    false
  end
end

port = Toxiproxy.running? ? 22220 : 6379

if Rails.env.test? && Toxiproxy.running?
  Toxiproxy.populate([{
    name: "redis",
    listen: "127.0.0.1:#{port}",
    upstream: "127.0.0.1:6379"
  }])
end

if Rails.env.test?
  Redis.current = Redis.new(db: 1, port: port)
else
  Redis.current = Redis.new(url: ENV['REDISTOGO_URL'])
end
