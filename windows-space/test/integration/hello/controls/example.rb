# copyright: 2018, The Authors

title "sample section"

# you add controls here
control "tmp-1.0" do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title "Create /tmp directory"             # A human-readable title
  desc "An optional description..."

  describe etc_hosts.where { ip_address == '127.0.0.1' } do
    its('ip_address') { should cmp [] }
    its('primary_name') { should cmp [] }
  end
end

control 'InSpec Version Check' do
  title 'Verify the InSpec version'

  # Get the InSpec version
  inspec_version = inspec.version

  # Output the InSpec version
  describe "InSpec Version" do
    subject { inspec_version }
    # it { should match /5.22.11/ }
    # it { should match /5.22.3/ }
    it { should match /4.24.32/ }
  end
end
