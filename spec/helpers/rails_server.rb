require 'fileutils'
require 'find'
require 'net/http'
require 'uri'

module Spec
  module Helpers
    class RailsServer
      attr_reader :rails_root, :rails_version, :name

      def initialize(options)
        options.assert_valid_keys(
          :name, :template_paths, :runtime_base_directory,
          :rails_version, :rails_env, :additional_gemfile_lines
        )

        @name = options[:name] || raise(ArgumentError, "You must specify a name for the Rails server")

        @template_paths = options[:template_paths] || raise(ArgumentError, "You must specify one or more template paths")
        @template_paths = Array(@template_paths).map { |t| File.expand_path(t) }

        @runtime_base_directory = options[:runtime_base_directory] || raise(ArgumentError, "You must specify a runtime_base_directory")
        @runtime_base_directory = File.expand_path(@runtime_base_directory)

        @rails_version = options[:rails_version] || :default
        @rails_env = (options[:rails_env] || 'production').to_s

        @additional_gemfile_lines = Array(options[:additional_gemfile_lines] || [ ])


        @rails_root = File.join(@runtime_base_directory, rails_version.to_s, name.to_s)
        @port = 20_000 + rand(10_000)
        @server_pid = nil
      end

      def start!
        do_start! unless server_pid
      end

      def stop!
        stop_server! if server_pid
      end

      def get(path, options = { })
        get_response(path, options).body.strip
      end

      def uri_for(path)
        uri_string = "http://localhost:#{@port}/#{path}"
        URI.parse(uri_string)
      end

      def get_response(path, options = { })
        uri = uri_for(path)
        data = Net::HTTP.get_response(uri)
        unless data.code.to_s == '200' || options[:ignore_status_code]
          raise "'#{uri}' returned #{data.code.inspect}, not 200; body was: #{data.body.strip}"
        end
        data
      end

      private
      attr_reader :template_paths, :runtime_base_directory, :rails_env, :additional_gemfile_lines, :port, :server_pid

      def do_start!
        Bundler.with_clean_env do
          with_rails_env do
            setup_directories!

            in_rails_root_parent do
              splat_bootstrap_gemfile!
              rails_new!
              update_gemfile!
            end

            in_rails_root do
              run_bundle_install!(:primary)
              splat_template_files!
              start_server!
              verify_server!
            end
          end
        end
      end

      def with_rails_env
        old_rails_env = ENV['RAILS_ENV']
        begin
          ENV['RAILS_ENV'] = rails_env
          yield
        ensure
          ENV['RAILS_ENV'] = old_rails_env
        end
      end


      def setup_directories!
        return if @directories_setup

        template_paths.each do |template_path|
          raise Errno::ENOENT, "You must specify template paths that exist; this doesn't: '#{template_path}'" unless File.directory?(template_path)
        end
        FileUtils.rm_rf(rails_root) if File.exist?(rails_root)
        FileUtils.mkdir_p(rails_root)

        @directories_setup = true
      end

      def in_rails_root(&block)
        Dir.chdir(rails_root, &block)
      end

      def in_rails_root_parent(&block)
        Dir.chdir(File.dirname(rails_root), &block)
      end

      def splat_bootstrap_gemfile!
        File.open("Gemfile", "w") do |f|
          rails_version_spec = if rails_version == :default then "" else ", \"= #{rails_version}\"" end
          f << <<-EOS
source 'https://rubygems.org'

gem 'rails'#{rails_version_spec}
EOS
        end

        run_bundle_install!(:bootstrap)
      end

      def rails_new!
        # This is a little trick to specify the exact version of Rails you want to create it with...
        # http://stackoverflow.com/questions/379141/specifying-rails-version-to-use-when-creating-a-new-application
        rails_version_spec = rails_version == :default ? "" : "_#{rails_version}_"
        cmd = "bundle exec rails #{rails_version_spec} new #{File.basename(rails_root)} -d sqlite3 -f -B"
        safe_system(cmd, "creating a new Rails installation for '#{name}'")
      end

      def update_gemfile!
        gemfile = File.join(rails_root, 'Gemfile')
        gemfile_contents = File.read(gemfile)

        # Since Rails 3.0.20 was released, a new version of the I18n gem, 0.5.2, was released that moves a constant
        # into a different namespace. (See https://github.com/mislav/will_paginate/issues/347 for more details.)
        # So, if we're running Rails 3.0.x, we lock the 'i18n' gem to an earlier version.
        gemfile_contents << "\ngem 'i18n', '= 0.5.0'\n" if rails_version && rails_version =~ /^3\.0\./

        # Apparently execjs released a version 2.2.0 that will happily install on Ruby 1.8.7, but which contains some
        # new-style hash syntax. As a result, we pin the version backwards in this one specific case.
        gemfile_contents << "\ngem 'execjs', '~> 2.0.0'\n" if RUBY_VERSION =~ /^1\.8\./

        gemfile_contents << additional_gemfile_lines.join("\n")

        File.open(gemfile, 'w') { |f| f << gemfile_contents }
      end

      def with_env(new_env)
        old_env = { }
        new_env.keys.each { |k| old_env[k] = ENV[k] }

        begin
          set_env(new_env)
          yield
        ensure
          set_env(old_env)
        end
      end

      def set_env(new_env)
        new_env.each do |k,v|
          if v
            ENV[k] = v
          else
            ENV.delete(k)
          end
        end
      end

      def splat_template_files!
        @template_paths.each do |template_path|
          Find.find(template_path) do |file|
            next unless File.file?(file)

            if file[0..(template_path.length)] == "#{template_path}/"
              subpath = file[(template_path.length + 1)..-1]
            else
              raise "#{file} isn't under #{template_path}?!?"
            end
            dest_file = File.join(rails_root, subpath)

            FileUtils.mkdir_p(File.dirname(dest_file))
            FileUtils.cp(file, dest_file)
          end
        end
      end

      def start_server!
        output = File.join(rails_root, 'log', 'rails-server.out')
        cmd = "rails server -p #{port} > '#{output}'"
        safe_system(cmd, "starting 'rails server' on port #{port}", :background => true)

        server_pid_file = File.join(rails_root, 'tmp', 'pids', 'server.pid')

        start_time = Time.now
        while Time.now < start_time + 15
          if File.exist?(server_pid_file)
            server_pid = File.read(server_pid_file).strip
            if server_pid =~ /^(\d{1,10})$/i
              @server_pid = Integer(server_pid)
              break
            end
          end
          sleep 0.1
        end
      end

      def verify_server!
        server_verify_url = "http://localhost:#{port}/working/rails_is_working"
        uri = URI.parse(server_verify_url)

        data = nil
        start_time = Time.now
        while (! data)
          begin
            data = Net::HTTP.get_response(uri)
          rescue Errno::ECONNREFUSED, EOFError
            raise if Time.now > (start_time + 20)
            # keep waiting
            sleep 0.1
          end
        end

        unless data.code.to_s == '200'
          raise "'#{server_verify_url}' returned #{data.code.inspect}, not 200"
        end
        result = data.body.strip

        unless result =~ /^Rails\s+version\s*:\s*(\d+\.\d+\.\d+)$/
          raise "'#{server_verify_url}' returned: #{result.inspect}"
        end
        actual_version = $1

        if rails_version != :default && (actual_version != rails_version)
          raise "We seem to have spawned the wrong version of Rails; wanted: #{rails_version.inspect} but got: #{actual_version.inspect}"
        end

        say "Successfully spawned a server running Rails #{actual_version} on port #{port}."
      end

      def is_alive?(pid)
        cmd = "ps -o pid #{pid}"
        results = `#{cmd}`
        results.split(/[\r\n]+/).each do |line|
          line = line.strip.downcase
          next if line == 'pid'
          if line =~ /^\d+$/i
            return true if Integer(line) == pid
          else
            raise "Unexpected output from '#{cmd}': #{results}"
          end
        end

        false
      end

      def stop_server!
        # We do this because under 1.8.7 SIGTERM doesn't seem to work, and it's actually fine to slaughter this
        # process mercilessly -- we don't need anything it has at this point, anyway.
        Process.kill("KILL", server_pid)

        start_time = Time.now

        while true
          if is_alive?(server_pid)
            raise "Unable to kill server at PID #{server_pid}!" if (Time.now - start_time) > 20
            say "Waiting for server at PID #{server_pid} to die."
            sleep 0.1
          else
            break
          end
        end

        say "Successfully terminated Rails server at PID #{server_pid}."

        @server_pid = nil
      end

      class CommandFailedError < StandardError
        attr_reader :directory, :command, :result, :output

        def initialize(directory, command, result, output)
          @directory = directory
          @command = command
          @result = result
          @output = output

          super(%{Command failed: in directory '#{directory}', we tried to run:
  % #{command}
  but got result: #{result.inspect}
  and output:
  #{output}})
        end
      end

      def run_bundle_install!(name)
        @bundle_installs_run ||= { }

        cmd = "bundle install"
        description = "running bundle install for #{name.inspect}"

        can_run_locally = @bundle_installs_run[name] || (ENV['FORTITUDE_SPECS_RAILS_GEMS_INSTALLED'] == 'true')

        if can_run_locally
          cmd << " --local"
        else
          description << " (WITHOUT --local flag)"
          say %{NOTE: We're running 'bundle install' without the --local flag, meaning it will
go out and access rubygems.org for the lists of the latest gems. This is a slow operation.
If you run multiple Rails specs at once, this will only happen once.

However, this only actually needs to happen once, ever, for a given Rails version; if you set
FORTITUDE_SPECS_RAILS_GEMS_INSTALLED=true (e.g.,
FORTITUDE_SPECS_RAILS_GEMS_INSTALLED=true bundle exec rspec spec/rails/...),
then we will skip this command and your spec will run much faster.}
        end

        # Sigh. Travis CI sometimes fails this with the following exception:
        #
        # Gem::RemoteFetcher::FetchError: Errno::ETIMEDOUT: Connection timed out - connect(2)
        #
        # So, we catch the command failure, look to see if this is the problem, and, if so, retry
        iterations = 0
        while true
          begin
            safe_system(cmd, description)
            break
          rescue CommandFailedError => cfe
            raise if (cfe.output !~ /Gem::RemoteFetcher::FetchError.*connect/i) || (iterations >= 5)
            say %{Got an exception trying to run 'bundle install'; sleeping and trying again (iteration #{iterations}):

#{cfe.output}}
            # keep going
          end

          sleep 1
          iterations += 1
        end

        @bundle_installs_run[name] ||= true
      end

      def say(s, newline = true)
        if newline
          $stdout.puts s
        else
          $stdout << s
        end
        $stdout.flush
      end

      def safe_system(cmd, notice = nil, options = { })
        say("#{notice}...", false) if notice

        total_cmd = if options[:background]
          "#{cmd} 2>&1 &"
        else
          "#{cmd} 2>&1"
        end

        output = `#{total_cmd}`
        raise CommandFailedError.new(Dir.pwd, total_cmd, $?, output) unless $?.success?
        say "OK" if notice

        output
      end
    end
  end
end
