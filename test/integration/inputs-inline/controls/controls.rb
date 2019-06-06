describe attribute("user", value: "value_from_dsl") do
  it { should eq "value_from_kitchen_yml_1" }
end

describe attribute("password") do
  it { should eq "value_from_kitchen_yml_2" }
end
