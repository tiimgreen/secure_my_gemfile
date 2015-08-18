module SecureMyGemfile
  class << self

    def gems_with_security_issues
      get_repo_files.map(&:name)
    end

    def gems_in_gemfile
      lockfile.specs
    end

    def names_of_gems_in_gemfile
      gems_in_gemfile.map(&:name)
    end

    private

    def lockfile
      Bundler::LockfileParser.new(Bundler.read_file('./Gemfile.lock'))
    end

    def potentially_insecure_gems
      (names_of_gems_in_gemfile & gems_with_security_issues)
    end

    def get_repo_files(**options)
      path = options.has_key?(:ruby_gem) ? "gems/#{options[:ruby_gem]}" : 'gems'
      Octokit.contents('rubysec/ruby-advisory-db', path: path)
    end
  end
end
