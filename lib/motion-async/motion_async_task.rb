class MotionAsyncTask < Android::Os::AsyncTask
  attr_reader :result
  attr_accessor :delay

  # Java is super picky about constructors, so we'll use a factory method
  def self.create(options={}, &block)
    MotionAsyncTask.new.tap do |task|
      options[:background] = block if block
      task.delay = options.delete(:delay)
      task.callbacks.merge!(options)
    end
  end

  def on(callback, &block)
    callbacks[callback] = block
    if callback == :completion && finished?
      # task already ran, but we'll call the completion block anyway
      block.call @result
    end
    self
  end

  # publishProgress must be passed an Array - we can make that easier
  def progress(progress)
    progress = [progress] unless progress.respond_to?(:[])
    publishProgress(progress)
  end

  def pending?
    status ==  Android::Os::AsyncTask::Status::PENDING
  end

  def running?
    status ==  Android::Os::AsyncTask::Status::RUNNING
  end

  def finished?
    status ==  Android::Os::AsyncTask::Status::FINISHED
  end

  def cancelled?
    isCancelled
  end

  ##########################
  ## AsyncTask event methods

  def onPreExecute
    call_if_defined :pre_execute, self
  end

  def onPostExecute(result)
    call_if_defined :completion, result
  end

  def doInBackground(params)
    sleep self.delay if self.delay
    @result = call_if_defined :background, self
  end

  def onProgressUpdate(progress)
    progress = progress.first if progress.size == 1
    call_if_defined :progress, progress
  end

  def onCancelled(result)
    call_if_defined :cancelled, result
  end

  private

  def callbacks
    @callbacks ||= {}
  end

  def call_if_defined(callback, param=nil)
    callbacks[callback].call(param) if callbacks[callback]
  end

end

