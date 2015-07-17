# MotionAsync provides a friendly Ruby wrapper around Android's AsyncTask.
#
# You can call it directly:
#
# @example
#   MotionAsync.async do
#     # some long task
#   end
#
# Or include the module to make the async command available wherever you need it
#
# @example
#   include MotionAsync
#   ...
#   async do
#     # some long task
#   end
#
# Usage:
#
# Run a block of code in the background:
#
# @example
#   async do
#     # some long operation
#   end
#
# Specify a block to execute when the operation completes. The return value of the async block is passed
# in as a parameter:
#
# @example
#   task = async do
#     some_expensive_calculation()
#   end
#   task.on :completion do |result|
#     p "The result was #{result}"
#   end
#
# Alternate syntax for the same example:
#
# @example
#   async.on(:background) do |task|
#     some_expensive_calculation()
#   end.on(:completion) do |result|
#     p "The result was #{result}"
#   end
#
# For progress updates, provide a :progress block, and periodically call #progress
# on the task object in the :background block. The :progress block is executed on the
# main thread.
#
# @example
#   async.on(:background) do |task|
#     100.times do |i|
#       # do some work
#       task.progress i
#     end
#   end.on(:progress) do |result|
#     p "Progress: #{progress + 1}% complete"
#   end
#
# :pre_execute is invoked before the async operation begins and :cancelled is called
# if the task is cancelled.
#
# @example
#   async.on(:background) do |task|
#     # long operation
#   end.on(:pre_execute) do
#     p "About to run a long operation"
#   end.on(:cancelled) do
#     p "Operation cancelled."
#   end
#
# async returns a reference to the task object (a subclass of AsyncTask); you can hold on to this
# in case you want to cancel it later. You can see if a task has been cancelled by calling
# cancelled?
#
# @example
# @async_task = async do |task|
#   image_urls.each do |image_url|
#     images << load_image(image_url)
#     break if task.cancelled?
#   end
# end
# ...
# def on_stop
#   @async_task.cancel
# end
#
# Delaying execution
#
# The #after method works just like #async, but takes a float as its first parameter to
# specify the number of seconds to delay before executing the async block.
#
# after(2) do
#   p "We did this 2 seconds later"
# end
#
# This works fine for relatively short delays (a few seconds at most), but you'd probably want to use a
# Handler for anything longer.
#
module MotionAsync

  def self.async(options={}, &block)
    MotionAsyncTask.create(options, &block).tap do |task|
      task.execute []
    end
  end

  def self.after(delay, options={}, &block)
    MotionAsync.async(options.merge(delay: delay), &block)
  end

  def async(options={}, &block)
    MotionAsync.async(options, &block)
  end

  def after(delay, options={}, &block)
    MotionAsync.after(delay, options, &block)
  end

end

