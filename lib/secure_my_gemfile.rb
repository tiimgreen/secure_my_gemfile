require 'toc'

require 'secure_my_gemfile/version'
require 'secure_my_gemfile/checks'

module SecureMyGemfile
  class << self

    def run!(**options)
      display_current_directory
      display_version if options[:version]
    end

    def display_current_directory
      puts "/#{File.basename(Dir.getwd)}".light_blue.bold
    end

    def display_version
      puts "secure_my_gemfile version #{SecureMyGemfile::VERSION}".light_blue
      exit 0
    end
  end
end
