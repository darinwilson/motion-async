describe "MotionAsync" do

  it "can be invoked with the full module name" do
    task = MotionAsync.async
    task.should.not.be.nil
  end

  it "can be invoked directly after being included" do
    # include statement is in main_activity
    main_activity.async_task.should.not.be.nil
  end

  it "won't croak if it doesn't have a background block" do
    # should.raise doesn't seem to be working quite right in Android :(
    success = true
    begin
      MotionAsync.async
    rescue Exception => e
      success = false
    end
    success.should.equal true
  end

  # NOTE: MainActivity runs a few tests as well - it turned out to be a little tricky
  # to orchestrate the threads correctly to run AsyncTask instances in a spec
  # environment. I'm sure it's doable, but I couldn't quite make it happen.

end

