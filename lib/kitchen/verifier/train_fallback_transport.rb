# encoding: utf-8
#
# Copyright 2017, Noah Kantrowitz
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

require 'shellwords'

module Train::Transports
  class Fallback < Train.plugin(1)
    name 'fallback'

    option :transport, required: true

    def connection(state = {})
      opts = merge_options(options, state || {})
      validate_options(opts)
      unless @connection && @connection_opts == opts
        @connection ||= Connection.new(opts)
        @connection_opts = opts.dup
      end
      @connection
    end

    class Connection < BaseConnection
      def kitchen_conn
        @kitchen_conn ||= options[:transport].connection(options[:state]).tap do |c|
          # Force the default logger no matter what so we don't get colored output.
          c.instance_eval { @logger = Logger.new(STDOUT); @logger.level = 100 }
        end
      end

      def os
        @os ||= OSCommon.new(self)
      end

      def file(path)
        @files[path] ||= \
          if os.windows?
            WindowsFile.new(self, path)
          elsif os.aix?
            AixFile.new(self, path)
          elsif os.solaris?
            UnixFile.new(self, path)
          else
            LinuxFile.new(self, path)
          end
      end

      def run_command(cmd)
        # Code borrowed from rspec-command.
        old_stdout = $stdout.dup
        old_stderr = $stderr.dup
        # Potential future improvement is to use IO.pipe instead of temp files, but
        # that would require threads or something to read contiuously since the
        # buffer is only 64k on the kernel side.
        Tempfile.open('capture_stdout') do |tmp_stdout|
          Tempfile.open('capture_stderr') do |tmp_stderr|
            $stdout.reopen(tmp_stdout)
            $stdout.sync = true
            $stderr.reopen(tmp_stderr)
            $stderr.sync = true
            result = nil
            begin
              # Inner block to make sure the ensure happens first.
              begin
                # For things that look like they are trying to do Unix shell stuff, wrap with sh -c.
                if cmd =~ /&&|\|\||>|</
                  cmd = Shellwords.join(['sh', '-c', cmd])
                end
                kitchen_conn.execute(cmd)
              ensure
                # Rewind.
                tmp_stdout.seek(0, 0)
                tmp_stderr.seek(0, 0)
                # Read in the output.
                result = CommandResult.new(tmp_stdout.read, tmp_stderr.read, 0)
              end
            rescue Exception => e
              if result
                # No way to know what the original exit status was, so just something non-zero.
                result.exit_status = 1
                result
              else
                # Something bad happened. Maybe this should just re-raise?
                CommandResult.new('', "Unknown error during fallback capture: #{e}", 1)
              end
            else
              result
            end
          end
        end
      ensure
        $stdout.reopen(old_stdout)
        $stderr.reopen(old_stderr)
      end

      def close
        if @kitchen_conn
          kitchen_conn.close
          @kitchen_conn = nil
        end
      end

      def uri
        "fallback://fallback"
      end

    end
  end
end
