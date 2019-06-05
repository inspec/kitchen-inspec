describe attribute("user", value: "value_from_dsl") do
  it { should eq "value_from_input_file_1" }
end

describe attribute("password") do
  it { should eq "value_from_input_file_2" }
end
