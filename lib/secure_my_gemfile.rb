require 'toc'
require 'bundler'
require 'octokit'
require 'yaml'
require 'open-uri'

require 'secure_my_gemfile/version'
require 'secure_my_gemfile/lockfile'
require 'secure_my_gemfile/gems_repo'
require 'secure_my_gemfile/checks'

module SecureMyGemfile
  class << self

    def run!(**options)
      puts ' Checking Gemfile.lock...'.light_blue.bold
      display_version if options[:version]
      print_errors
    end

    private

    def print_errors
      errors = check_for_insecurities(potentially_insecure_gems)
      print_status(errors)

      errors.each { |error| print_error(error) }
    end

    def display_current_directory
      puts ' Directory: ' + Dir.getwd.light_blue.bold
    end

    def display_version
      puts "secure_my_gemfile version #{SecureMyGemfile::VERSION}".light_blue
      exit 0
    end

    def get_gem_in_gemfile(ruby_gem)
      gems_in_gemfile.select { |g| g.name == ruby_gem }.first
    end

    def print_error(error)
      puts "   [" + "#{error[:name]} (#{error[:version]})".red.bold + "] #{error[:title].strip.bold.black}"

      if error[:patched_versions]
        puts "     * Please update #{error[:name]} to any of the following: #{error[:patched_versions]}"
      end

      puts '     * See more: ' + error[:url].light_blue + "\n\n"
    end

    def print_status(errors)
      if errors.empty?
        puts ' No insecure gems found!'.green.bold
      else
        puts ' ' + 'Insecure gems found:'.red.bold.underline
      end
    end
  end
end
