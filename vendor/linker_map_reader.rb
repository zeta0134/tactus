# Copyright (c) 204 Something Nerdy Studios LLC
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

linker_filename = ARGV[0]

lines = []
File.open(linker_filename, "r").each_line do |line|
  lines << line.chomp
end

#segment_list_start = lines.find_index {|l| l.match /^Segment list/}
#puts lines[segment_list_start]
#segment_list_end = lines.find_index {|l| l.match /^Exports list by name/} - 1
exports_list_start = lines.find_index {|l| l.match /^Exports list by name/}
#puts lines[exports_list_start]
exports_list_end = lines.find_index {|l| l.match /^Exports list by value/} - 1

#segment_list = lines[(segment_list_start + 4)..(segment_list_end - 2)]
exports_list = lines[(exports_list_start + 2)..(exports_list_end - 3)]
#puts segment_list.inspect
#puts segment_list.first.split.inspect
#puts exports_list.inspect
#puts exports_list.first.split.inspect


#segments = []
# "Name Start End Size Align"
#segment_list.each do |segment_string|
#  pieces = segment_string.split
#  segments << {
#    name: pieces[0],
#    start: pieces[1].to_i(16),
#    end: pieces[2].to_i(16),
#    size: pieces[3].to_i(16),
#    align: pieces[4].to_i(16)
#  }
#end

#puts segments[7]

exports = {}
exports_list = exports_list.join(" ").split.each_slice(3).to_a

export_names = []

exports_list.filter {|e| e[0].match /_START__$/}.each do |export_start|
  export_names << export_start[0][2..-9]
end

exports_list_hash = {}
exports_list.each do |export_entry|
  exports_list_hash[export_entry[0]] = export_entry[1].to_i(16)
end

#puts exports_list_hash

#puts export_names

export_names.each do |export_name|
  exports[export_name] = {
    size: exports_list_hash["__" + export_name + "_LAST__"] - exports_list_hash["__" + export_name + "_START__"],
    capacity: exports_list_hash["__" + export_name + "_SIZE__"]
  }
end

#puts exports

full_exports = {}

exports.each do |name, stats|
  if stats[:size] == stats[:capacity]
    full_exports[name] = stats
  end
end
# Now we print out the usage of them in a pretty fashion
longest_key = 0
exports.keys.each do |key|
  if key.length > longest_key
    longest_key = key.length
  end
end
full_exports.each do |name, stats|
  #if stats[:size] != stats[:capacity]
    print name.rjust(longest_key, " ")
    print " "
    fill_amt = (stats[:size].to_f/stats[:capacity])
    fill = (fill_amt * 100).round(2).to_s.split(".")
    print fill[0].rjust(3, " ")
    print "."
    print fill[1].ljust(2, "0")
    print " "
    print "["
    fill_str = "X"*(50*fill_amt)
    empty_str = "-"*(50- fill_str.length)
    print fill_str
    print empty_str
    print "]"
    print " "
    print stats[:size]
    print "/"
    print stats[:capacity]
    #print ((stats[:size].to_f/stats[:capacity] * 100).round(2)).to_s.rjust(5, " ")
    puts
  #end
end


puts
puts "===================================================="
puts

# Now we print out the usage of them in a pretty fashion
list_print_index = 0
exports.each do |name, stats|
  if stats[:size] != stats[:capacity]
    if list_print_index % 2 == 1
      # make it grey
      print "\e[97m"
    else
      print "\e[97m\e[48;5;237m"
    end
    print name.rjust(longest_key, " ")
    print " "
    fill_amt = (stats[:size].to_f/stats[:capacity])
    fill = (fill_amt * 100).round(2).to_s.split(".")
    print fill[0].rjust(3, " ")
    print "."
    print fill[1].ljust(2, "0")
    print " "
    print "["
    fill_str = "X"*(64*fill_amt)
    empty_str = "-"*(64- fill_str.length)
    print fill_str
    print empty_str
    print "]"
    print " "
    print stats[:size].to_s.rjust(7,' ')
    print " / "
    print stats[:capacity].to_s.ljust(8, ' ')
    print (stats[:capacity] - stats[:size]).to_s.rjust(7, ' ')
    print " remaining"
    
    print "\e[0m"
    #print ((stats[:size].to_f/stats[:capacity] * 100).round(2)).to_s.rjust(5, " ")
    puts
    list_print_index += 1
  end
end
