require 'test_helper'
require 'resque/failure/redis'
require 'digest/sha1'

class RetryTest < Minitest::Test
  def setup
    Resque.redis.flushall
    @worker = Resque::Worker.new(:testing, 'testing-arg1')
    @worker.register_worker
    Resque::Failure.backend = Resque::Failure::Redis
  end

  def teardown
    Resque.redis.flushall
    Resque.workers.each { |w| w.unregister_worker }
  end

  def test_retry_delayed_with_specific_queue
    Resque.enqueue_to('testing-arg1', JobRetryWithSpecificQueue, 'arg1')
    Resque.expects(:enqueue_to).with('testing-arg1', JobRetryWithSpecificQueue, 'arg1')

    perform_next_job(@worker)
  end
end
