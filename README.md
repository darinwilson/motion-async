# motion-async

motion-async is a gem for RubyMotion Android that provides a friendly Ruby wrapper around Android's [AsyncTask:](https://developer.android.com/reference/android/os/AsyncTask.html)

> AsyncTask enables proper and easy use of the UI thread. This class allows [you] to perform background operations and publish results on the UI thread without having to manipulate threads and/or handlers.
>
> AsyncTask is designed to be a helper class around Thread and Handler and does not constitute a generic threading framework. AsyncTasks should ideally be used for short operations (a few seconds at the most.)

AsyncTask must be loaded on the UI thread, _and must only be executed once._ See [the documentation](https://developer.android.com/reference/android/os/AsyncTask.html) for more details.

## Setup

Gemfile:

```ruby
gem "motion-async"
```

then run `bundle` on the command line.

## Usage

The main entry point is the `MotionAsync.async` function, which creates, and then executes the async code with the options you provide (see below for details).

```ruby
MotionAsync.async do
  # some long operation
end
```

You can also `include MotionAsync` to have access to the `async` function without the module prefix:

```ruby
include MotionAsync
...
async do
  # some long operation
end
```

`async` takes a block, which is the code that should be executed in the background. You can optionally specify callback blocks that are run at various points during the tasks's lifecycle:

  * `:pre_execute` : before the background task is executed
  * `:completion` : when the task finishes
  * `:progress` : whenever `progress` is called on the task object
  * `:cancelled` : if the task is cancelled

These callbacks can be added with the `on` method, or passed in as options to `async`.

This:

```ruby
async do
  # some long operation
end.on(:completion) do |result|
  # process result
end
```

is the same as this:

```ruby
async(
  completion: -> (result) {
    # process result
  }
) do
  # some long operation
end
```

To avoid the awkward syntax of the latter example, you can use the `:background` option to specify the async code:

```ruby
async(
  background: -> {
    # some long operation
  },
  completion: -> (result) {
    # process result
  }
)
```

## Examples

Run a block of code in the background:

```ruby
async do
  # some long operation
end
```

Specify a block to execute when the operation completes. The return value of the async block is passed
in as a parameter:

```ruby
task = async do
  some_expensive_calculation()
end
task.on :completion do |result|
  p "The result was #{result}"
end
```

Alternate syntax for the same example:

```ruby
async do
  some_expensive_calculation()
end.on(:completion) do |result|
  p "The result was #{result}"
end
```

### Progress Indicators

For progress updates, provide a `:progress block`, and periodically call `#progress` on the task object in the background block. The `:progress` block is executed on the main thread.

```ruby
async do |task|
  100.times do |i|
    # do some work
    task.progress i
  end
end.on(:progress) do |progress_value|
  p "Progress: #{progress_value + 1}% complete"
end
```

### Chaining

Calls to `on` are chainable:

```ruby
async do |task|
  100.times do |i|
    # do some work
    task.progress i
  end
end.on(:progress) do |progress_value|
  p "Progress: #{progress_value + 1}% complete"
end.on(:completion) do |result|
  p "The result was #{result}"
end
```

### Other Callbacks

`:pre_execute` is invoked before the async operation begins and `:cancelled` is called if the task is cancelled.

```ruby
async do
  # long operation
end.on(:pre_execute) do
  p "About to run a long operation"
end.on(:cancelled) do
  p "Operation cancelled."
end
```

### Canceling a Task

`async` returns a reference to the task object (a subclass of `AsyncTask`); you can hold on to this
in case you want to cancel it later. You can see if a task has been cancelled by calling
`cancelled?` The Android docs recommend checking this value periodically during task execution
so you can exit gracefully.

```ruby
@async_task = async do |task|
  image_urls.each do |image_url|
    images << load_image(image_url)
    break if task.cancelled?
  end
end
...
# e.g. in an Activity or Fragment
def onStop
 @async_task.cancel(true) # passing in true indicates that the task should be interrupted
end
```

### Other Task States

```ruby
task.pending?
task.running?
task.finished?
```

## Development

### Tests

It's a little tricky to test background threads in a unit test context. I went through a number of blog posts and SO questions, but never could manage to get it to work.

So, we've got a few tests in `main_spec.rb` and then a bunch in `main_activity.rb` which are run simply by running the app in this codebase via `rake`. I'm not especially proud of this, but figured it was better than nothing. If anyone can show me a better way, I'd love to see it.

