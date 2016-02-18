# encoding: utf-8
#
# Author:: Fletcher Nichol (<fnichol@chef.io>)
# Author:: Christoph Hartmann (<chartmann@chef.io>)
#
# Copyright (C) 2015, Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../spec_helper'

require 'logger'

require 'kitchen/verifier/inspec'
require 'kitchen/transport/ssh'
require 'kitchen/transport/winrm'

describe Kitchen::Verifier::Inspec do

  let(:logged_output)     { StringIO.new }
  let(:logger)            { Logger.new(logged_output) }
  let(:config)            { {} }
  let(:transport_config)  { {} }

  let(:platform) do
    instance_double('Kitchen::Platform', os_type: nil, shell_type: nil)
  end

  let(:suite) do
    instance_double('Kitchen::Suite', name: 'germany')
  end

  let(:transport) do
    instance_double(
      'Kitchen::Transport::Dummy',
      name: 'wickedsauce',
      diagnose: transport_config,
    )
  end

  let(:instance) do
    instance_double(
      'Kitchen::Instance',
      name: 'coolbeans',
      logger: logger,
      platform: platform,
      suite: suite,
      transport: transport,
      to_str: 'instance',
    )
  end

  before do
    allow(transport).to receive(:instance).and_return(instance)

    @root = Dir.mktmpdir
    config[:test_base_path] = @root
  end

  after do
    FileUtils.remove_entry(@root)
  end

  let(:verifier) do
    Kitchen::Verifier::Inspec.new(config).finalize_config!(instance)
  end

  it 'verifier api_version is 1' do
    expect(verifier.diagnose_plugin[:api_version]).to eq(1)
  end

  it 'plugin_version is set to Kitchen::Verifier::INSPEC_VERSION' do
    expect(verifier.diagnose_plugin[:version])
      .to eq(Kitchen::Verifier::INSPEC_VERSION)
  end

  describe 'configuration' do
    # nothing yet, woah!
  end

  context 'with an ssh transport' do

    let(:transport_config) do
      {
        hostname: 'boogie',
        port: "I shouldn't be used",
        username: 'dance',
        ssh_key: '/backstage/pass',
        keepalive: 'keepalive',
        keepalive_interval: 'forever',
        connection_timeout: 'nope',
        connection_retries: 'thousand',
        connection_retry_sleep: 'sleepy',
        max_wait_until_ready: 42,
        compression: 'maxyo',
        compression_level: 'pico',
      }
    end

    let(:transport) do
      Kitchen::Transport::Ssh.new(transport_config)
    end

    let(:runner) do
      instance_double('Inspec::Runner')
    end

    before do
      allow(runner).to receive(:add_tests)
      allow(runner).to receive(:run).and_return 0
    end

    it 'constructs a Inspec::Runner using transport config data and state' do
      config[:sudo] = 'jellybeans'

      expect(Inspec::Runner).to receive(:new)
        .with(
          hash_including(
            'backend' => 'ssh',
            'logger' => logger,
            'sudo' => 'jellybeans',
            'host' => 'boogie',
            'port' => 123,
            'user' => 'dance',
            'keepalive' => 'keepalive',
            'keepalive_interval' => 'forever',
            'connection_timeout' => 'nope',
            'connection_retries' => 'thousand',
            'connection_retry_sleep' => 'sleepy',
            'max_wait_until_ready' => 42,
            'compression' => 'maxyo',
            'compression_level' => 'pico',
            'key_files' => ['/backstage/pass'],
          ),
        )
        .and_return(runner)

      verifier.call(port: 123)
    end

    it 'constructs an Inspec::Runner with a specified inspec output format' do
      config[:format] = 'documentation'

      expect(Inspec::Runner).to receive(:new)
        .with(
          hash_including(
            'format' => 'documentation',
          ),
        )
        .and_return(runner)

      verifier.call(port: 123)
    end

    it 'find test path for runner' do
      # create_test_files
      allow(Inspec::Runner).to receive(:new).and_return(runner)
      expect(runner).to receive(:add_tests).with(array_including([
        File.join(
          config[:test_base_path],
          'germany',
        ),
      ]))

      verifier.call({})
    end

    it 'find test path for runner if legacy' do
      create_legacy_test_directories
      allow(Inspec::Runner).to receive(:new).and_return(runner)
      expect(runner).to receive(:add_tests).with(array_including([
        File.join(
          config[:test_base_path],
          'germany', 'inspec'
        ),
      ]))

      verifier.call({})
    end

    it 'calls #run on the runner' do
      allow(Inspec::Runner).to receive(:new).and_return(runner)
      expect(runner).to receive(:run)

      verifier.call({})
    end
  end

  context 'with an winrm transport' do

    let(:transport_config) do
      {
        username: 'dance',
        password: 'party',
        connection_retries: 'thousand',
        connection_retry_sleep: 'sleepy',
        max_wait_until_ready: 42,
      }
    end

    let(:transport) do
      Kitchen::Transport::Winrm.new(transport_config)
    end

    let(:runner) do
      instance_double('Inspec::Runner')
    end

    before do
      allow(runner).to receive(:add_tests)
      allow(runner).to receive(:run).and_return 0
    end

    it 'constructs a Inspec::Runner using transport config data and state' do
      expect(Inspec::Runner).to receive(:new)
        .with(
          hash_including(
            'backend' => 'winrm',
            'logger' => logger,
            'host' => 'win.dows',
            'port' => 123,
            'user' => 'dance',
            'password' => 'party',
            'connection_retries' => 'thousand',
            'connection_retry_sleep' => 'sleepy',
            'max_wait_until_ready' => 42,
          ),
        )
        .and_return(runner)

      verifier.call(hostname: 'win.dows', port: 123)
    end
  end

  context 'with an unsupported transport' do

    it '#call raises a UserError' do
      expect { verifier.call({}) }.to raise_error(Kitchen::UserError)
    end
  end

  def create_legacy_test_directories
    base = File.join(config[:test_base_path], 'germany')
    FileUtils.mkdir_p(File.join(base, 'inspec'))
    FileUtils.mkdir_p(File.join(base, 'serverspec'))
  end
end
