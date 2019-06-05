# encoding: utf-8
val_user = attribute("user", default: "value_from_dsl", description: "An identification for the user")
val_password = attribute("password", description: "A value for the password")

describe val_user do
  it { should eq "value_from_kitchen_yml_1" }
end

describe val_password do
  it { should eq "value_from_kitchen_yml_2" }
end
