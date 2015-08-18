module SecureMyGemfile
  class << self
    private

    def potentially_insecure_gems
      (names_of_gems_in_gemfile & gems_with_security_issues)
    end

    def check_for_insecurities(potentially_insecure_gems)
      errors = []
      print ' '

      potentially_insecure_gems.each do |ruby_gem|
        get_repo_files(ruby_gem: ruby_gem).each do |error_file|
          gem_in_gemfile = get_gem_in_gemfile(ruby_gem)
          file = YAML.load(open(error_file.download_url).read)

          current_version_vulnerable = true

          if using_patched_version?(file, ruby_gem) || using_unaffected_version?(file, ruby_gem)
            current_version_vulnerable = false
            print '.'.bold.green
          end

          next unless current_version_vulnerable
          print '.'.bold.red

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

    def using_patched_version?(file, ruby_gem)
      if file['patched_versions']
        gem_in_gemfile = get_gem_in_gemfile(ruby_gem)

        file['patched_versions'].each do |version|
          if Gem::Dependency.new('', version).match?('', gem_in_gemfile.version.version)
            return true
          end
        end
      end

      false
    end

    def using_unaffected_version?(file, ruby_gem)
      if file['unaffected_versions']
        gem_in_gemfile = get_gem_in_gemfile(ruby_gem)

        file['unaffected_versions'].each do |version|
          begin
            if Gem::Dependency.new('', version).match?('', gem_in_gemfile.version.version)
              return true
            end
          rescue Gem::Requirement::BadRequirementError
            version.split(', ').each do |separate_version|
              if Gem::Dependency.new('', separate_version).match?('', gem_in_gemfile.version.version)
                return true
              end
            end
          end
        end
      end

      false
    end
  end
end
