module SecureMyGemfile
  class << self
    private

    def get_repo_files(**options)
      path = options.has_key?(:ruby_gem) ? "gems/#{options[:ruby_gem]}" : 'gems'
      Octokit.contents('rubysec/ruby-advisory-db', path: path)
    end

    def gems_with_security_issues
      get_repo_files.map(&:name)
    end
  end
end
