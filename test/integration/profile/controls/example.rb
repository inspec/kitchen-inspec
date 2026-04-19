# copyright: Copyright (c) 2015-2025 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
# license: All rights reserved

title "/tmp profile"

# you add controls here
control "tmp-1.0" do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title "Create /tmp directory"             # A human-readable title
  desc "An optional description..."
  describe file("/tmp") do                  # The actual test
    it { should be_directory }
  end
end
