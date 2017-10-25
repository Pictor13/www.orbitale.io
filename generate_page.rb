#!/usr/bin/env ruby

title = ARGV[0]

if !title
    loop do
        print "\nTitle ? > "
        title = gets.chomp
        break if title != "" and title != nil
    end
end

date_simple = Time.now.strftime("%Y-%m-%d")
date_full = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")

template = """\
---
layout: post
title:  '#{title}'
date:   #{date_full}
---

Hello world!
"""

title_simple = title.downcase.gsub(/[^a-zA-Z0-9]+/i, "-").gsub(/--+|^-|-$/, "")

filename = "#{date_simple}-#{title_simple}.md"

new_file = File.new("_posts/#{filename}", "w")

new_file.puts(template)

print "Title: #{filename}"
print "\nTemplate:#{template}"
print "\n\nYou can now edit your new article!"
