require 'yaml'

module CachedHash

  class CachedHash < Hash 

    attr_accessor :f

    def initialize(f)
      @f = f
      self.replace(YAML::load_file(f)) if File.exists?(f)
    end

    def get(key)
      self[key] ||= lookup(key)
    end

    def save
      File.open(f, 'w') do |out|
        YAML.dump(self, out)
      end
    end

  end

end
