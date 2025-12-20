# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name "kitchen-inspec"

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list "os_prepare::default"

# Specify a custom source for a single cookbook:
cookbook "os_prepare", path: "./test/cookbooks/os_prepare"
cookbook "ssh-hardening", git: "https://github.com/dev-sec/chef-ssh-hardening.git"
