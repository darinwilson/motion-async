class MainActivity < Android::App::Activity
  include MotionAsync

  def onCreate(savedInstanceState)
    super
    test "pre_execute run before background" do
      ary = []
      task = MotionAsync.async(
        pre_execute: -> {
          ary.push(0)
        },
        background: -> {
          ary.push(1)
        },
        completion: -> {
          verify_array(ary, 2)
        }
      )
    end

    test "progress called during background task" do
      ary = []
      task = MotionAsync.async(
        background: ->(task) {
          10.times do |i|
            task.progress i
          end
        },
        progress: ->(value) {
          ary.push(value)
        },
        completion: -> {
          verify_array(ary, 10)
        }
      )
    end

    test "task reports correct status" do
      success = true
      task = MotionAsync.async(
        background: ->(task) {
          success &&= task.running?
        },
        completion: -> {
          if success
            pass_test
          else
            fail_test
          end
        }
      )
    end

    test "task can be cancelled" do
      task = MotionAsync.async(
        background: ->(task) {
          10.times do
            sleep 1
            break if task.cancelled?
          end
        },
        cancelled: -> {
            pass_test
        },
        completion: -> {
          # we should never get here
          fail_test
        }
      )
      task.cancel(true)
    end

    test "completion block executes even if it's set after task completes" do
      task = MotionAsync.async(
        background: -> {
          # no-op
        }
      )
      task.on(:completion) do |result|
        pass_test
      end
    end

    test "invoking with #after delays execution" do
      start_time = Time.now
      MotionAsync.after(2.0) do
        #no-op
      end.on(:completion) do
        diff = Time.now - start_time
        if diff >= 2.0 && diff <= 3.0
          pass_test
        else
          fail_test "Code invoked with #after executed in #{diff} seconds (expected ~2)"
        end
      end
    end

  end

  def test(name, &block)
    puts name
    block.call
  end

  # used by specs
  def async_task
    async
  end

  private

  # This is a simple tool to help us make sure things execute in the order we expect. We're expecting
  # an array whose values match each index, i.e [0, 1, 2, 3...]
  def verify_array(ary, count)
    fail_test "expected #{count} elements; got #{ary.size}" unless ary.size == count
    ary.each_with_index do |elt, i|
      if elt != i
        fail_test "#{ary.inspect}"
      end
    end
    pass_test
  end

  def pass_test
    puts "  -> SUCCESS"
  end

  def fail_test(message=nil)
    message = message.nil? ? "" : ": (#{message})"
    puts "  -> FAILED#{message}"
  end

end
