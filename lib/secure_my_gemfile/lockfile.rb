module SecureMyGemfile
  class << self
    private

    def lockfile
      Bundler::LockfileParser.new(Bundler.read_file('./Gemfile.lock'))
    end

    def gems_in_gemfile
      lockfile.specs
    end

    def names_of_gems_in_gemfile
      gems_in_gemfile.map(&:name)
    end
  end
end
