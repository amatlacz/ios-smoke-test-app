#!/usr/bin/env ruby

require 'run_loop'
require 'luffa'

cucumber_args = "#{ARGV.join(' ')}"

working_directory = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'CalSmokeApp'))

# on-simulator tests of features in test/cucumber
Dir.chdir(working_directory) do

  Luffa.unix_command('bundle install',
                     {:pass_msg => 'bundled',
                      :fail_msg => 'could not bundle'})

  Luffa.unix_command('make clean',
                     {:pass_msg => 'cleaned',
                      :fail_msg => 'could not clean'})

  Luffa.unix_command('make app',
                     {:pass_msg => 'built app',
                      :fail_msg => 'could not build app'})

  xcode = RunLoop::Xcode.new
  xcode_version = xcode.version
  sim_major = xcode_version.major + 2
  sim_minor = xcode_version.minor

  sim_version = RunLoop::Version.new("#{sim_major}.#{sim_minor}")

  devices = {
    :air => 'iPad Air',
    :iphone4s => 'iPhone 4s',
    :iphone5s => 'iPhone 5s',
    :iphone6 => 'iPhone 6',
    :iphone6plus => 'iPhone 6 Plus'
  }

  simulators = RunLoop::SimControl.new.simulators

  env_vars = {'APP_BUNDLE_PATH' => './CalSmoke-cal.app'}
  passed_sims = []
  failed_sims = []
  devices.each do |key, name|
    cucumber_cmd = "bundle exec cucumber -p simulator #{cucumber_args}"

    match = simulators.find do |sim|
      sim.name == name && sim.version == sim_version
    end

    env_vars = {'DEVICE_TARGET' => match.udid}

    exit_code = Luffa.unix_command(cucumber_cmd, {:exit_on_nonzero_status => false,
                                                  :env_vars => env_vars})
    if exit_code == 0
      passed_sims << name
    else
      failed_sims << name
    end
  end

  Luffa.log_info '=== SUMMARY ==='
  Luffa.log_info ''
  Luffa.log_info 'PASSING SIMULATORS'
  passed_sims.each { |sim| Luffa.log_info(sim) }
  Luffa.log_info ''
  Luffa.log_info 'FAILING SIMULATORS'
  failed_sims.each { |sim| Luffa.log_info(sim) }

  sims = devices.count
  passed = passed_sims.count
  failed = failed_sims.count

  puts ''
  Luffa.log_info "passed on '#{passed}' out of '#{sims}'"

  # if none failed then we have success
  exit 0 if failed == 0

  # the travis ci environment is not stable enough to have all tests passing
  exit failed unless Luffa::Environment.travis_ci?

  # we'll take 75% passing as good indicator of health
  expected = 75
  actual = ((passed.to_f/sims.to_f) * 100).to_i

  if actual >= expected
    Luffa.log_pass "We failed '#{failed}' sims, but passed '#{actual}%' so we say good enough"
    exit 0
  else
    Luffa.log_fail "We failed '#{failed}' sims, which is '#{actual}%' and not enough to pass"
    exit 1
  end
end