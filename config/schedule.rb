set :output, "/Users/ios4/Documents/work/self_test/bing_saver/cron_log.log"
every 1.days, :at => '10:00 am'  do
  # command "echo 'you can use raw cron syntax too' >> /Users/ios4/Documents/work/self_test/whenever_test/infer.txt"
  command "/Users/ios4/Documents/work/self_test/bing_saver/test.rb"
  # runner "MyModel.some_process"
  # rake "my:rake:task"
  # command "/usr/bin/my_great_command"
end
