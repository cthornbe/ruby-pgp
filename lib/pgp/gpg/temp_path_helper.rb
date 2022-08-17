require 'tmpdir'

module GPG
  class TempPathHelper
    def self.create(&block)
      path = File.join(Dir.tmpdir, random_string)

      yield(path) if block

      path
    ensure
      delete(path)
    end

    private

    def self.delete(path)
      if File.exist?(path)
        File.delete(path)
      end
    end

    def self.random_string(length=20)
      (0...length).map { (65 + rand(26)).chr }.join
    end
  end
end