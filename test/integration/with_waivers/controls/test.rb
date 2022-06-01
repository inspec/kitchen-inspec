control 'passing-test' do
  describe 'true' do
    it { should cmp 'true' }
  end
end


control 'failing-test' do
  describe 'false' do
    it { should cmp 'true' }
  end
end
