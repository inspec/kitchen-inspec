# encoding: utf-8

# This is an InSpec test, that will be successful the first run. If it is
# executed the second time, the test will fail
path = "/tmp/file"
describe file(path) do
  it { should_not exist }
end

# HACK: create a second file to fail tests if they run twice
describe command("mkdir -p #{path}") do
  its("exit_status") { should eq 0 }
end
