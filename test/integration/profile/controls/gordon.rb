# encoding: utf-8
# copyright: 2015, Chef Software, Inc.
# license: All rights reserved

title "Gordon Config Checks"

control "gordon-1.0" do
  impact 0.7
  title "Verify the version number of Gordon"
  desc "An optional description..."
  describe gordon_config do
    its("version") { should eq("1.0") }
  end
end
