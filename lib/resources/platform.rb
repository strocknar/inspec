# encoding: utf-8

module Inspec::Resources
  class PlatformResource < Inspec.resource(1)
    name 'platform'
    desc 'Use the platform InSpec resource to test the platform on which the system is running.'
    example "
      describe platform.name do
        it { should eq 'redhat' }
      end

      describe platform.family?('unix') do
        it { should eq true }
      end
    "

    def initialize
      @platform = inspec.backend.os
    end

    # add helper methods for easy access of properties
    %w{name family release arch}.each do |property|
      define_method(property.to_sym) do
        @platform.send(property)
      end
    end

    def [](name)
      # convert string to symbol
      name = name.to_sym if name.is_a? String
      @platform[name]
    end

    def platform?(name)
      @platform.name == name ||
        @platform.family_hierarchy.include?(name)
    end

    def family?(family)
      @platform.family_hierarchy.include?(family)
    end

    def families
      @platform.family_hierarchy
    end

    def supported?(supports)
      return true if supports.nil? || supports.empty?

      status = true
      supports.each do |s|
        s.each do |k, v|
          # ignore the inspec check
          if k == :inspec
            next
          elsif %i(os_family os-family platform_family platform-family).include?(k)
            status = family?(v)
          elsif %i(os platform).include?(k)
            status = platform?(v)
          elsif %i(os_name os-name platform_name platform-name).include?(k)
            status = name == v
          elsif k == :release
            status = check_release(v)
          else
            status = false
          end
          break if status == false
        end
        return true if status == true
      end

      status
    end

    def to_s
      'Platform Detection'
    end

    private

    def check_release(value)
      # allow wild card matching
      if value.include?('*')
        cleaned = Regexp.escape(value).gsub('\*', '.*?')
        !(release =~ /#{cleaned}/).nil?
      else
        release == value
      end
    end
  end
end
