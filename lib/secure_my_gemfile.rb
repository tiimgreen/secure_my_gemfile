require 'toc'
require 'bundler'
require 'octokit'
require 'yaml'
require 'open-uri'

require 'secure_my_gemfile/version'
require 'secure_my_gemfile/checks'
require 'secure_my_gemfile/lockfile'

module SecureMyGemfile
  class << self

    def run!(**options)
      puts ' Checking Gemfile.lock...'.light_blue.bold
      # display_current_directory


      # TODO: Remove when deploying
      login_github

      display_version if options[:version]
      print_errors
    end

    private

    def print_errors
      unless potentially_insecure_gems.any?
        return puts(' No insecure gems found!'.green.bold)
      end


      errors = check_for_insecurities(potentially_insecure_gems)

      puts ' ' + 'Insecure gems found:'.red.bold.underline

      errors.each do |error|
        puts "   [" + "#{error[:name]} (#{error[:version]})".red.bold + "] #{error[:title].strip.bold.black}"

        if error[:patched_versions]
          puts "     * Please update #{error[:name]} to any of the following: #{error[:patched_versions]}"
        end

        puts '     * See more: ' + error[:url].light_blue + "\n\n"
      end
    end

    def display_current_directory
      puts ' Directory: ' + Dir.getwd.light_blue.bold
    end

    def display_version
      puts "secure_my_gemfile version #{SecureMyGemfile::VERSION}".light_blue
      exit 0
    end

    def login_github
      Octokit.configure do |c|
        c.login = 'tiimgreen'
        c.password = ENV["GITHUB_PASSWORD"]
      end
    end

    def check_for_insecurities(potentially_insecure_gems)
      errors = []

      print ' '

      potentially_insecure_gems.each do |ruby_gem|
        get_repo_files(ruby_gem: ruby_gem).each do |error_file|
          gem_in_gemfile = gems_in_gemfile.select { |g| g.name == ruby_gem }.first
          file = YAML.load(open(error_file.download_url).read)

          current_version_vulnerable = true

          if file['patched_versions']
            file['patched_versions'].each do |version|
              if Gem::Dependency.new('', version).match?('', gem_in_gemfile.version.version)
                current_version_vulnerable = false
              end
            end
          end

          if file['unaffected_versions']
            file['unaffected_versions'].each do |version|
              begin
                if Gem::Dependency.new('', version).match?('', gem_in_gemfile.version.version)
                  current_version_vulnerable = false
                  puts "Errored due to unaffected_versions"
                end
              rescue Gem::Requirement::BadRequirementError
                version.split(', ').each do |version|
                  if Gem::Dependency.new('', version).match?('', gem_in_gemfile.version.version)
                    current_version_vulnerable = false
                  end
                end
              end
            end
          end

          print current_version_vulnerable ? '.'.bold.red : '.'.bold.green

          next unless current_version_vulnerable

          errors << {
            name: ruby_gem,
            version: gem_in_gemfile.version.version,
            title: file['title'],
            patched_versions: file['patched_versions'],
            url: file['url']
          }
        end
      end

      puts ""

      errors
    end
  end
end

SecureMyGemfile.run!
