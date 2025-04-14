#!/usr/bin/env ruby
require 'fileutils'

# Find the problematic file
file_path = 'C:/Ruby27-x64/lib/ruby/gems/2.7.0/gems/activesupport-6.1.7.10/lib/active_support/logger_thread_safe_level.rb'

# Create a backup
FileUtils.cp(file_path, "#{file_path}.bak")

# Read the file content
content = File.read(file_path)

# Add the missing require at the top
patched_content = "require 'logger'\n\n" + content

# Replace the file with our patched version
File.open(file_path, 'w') do |file|
  file.write(patched_content)
end

puts "Successfully patched #{file_path}"