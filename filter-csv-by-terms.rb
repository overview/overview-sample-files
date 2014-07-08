# filter-csv-by-term.rb
# outputs only those rows of a CSV which contain a given term as substring  
# Hard-coded for raw Wikileaks cables.csv, adds heads to output

require 'csv'

# Usage. Can specify files (and a limit on rows) but not 
if ARGV.length < 3
  puts("USAGE: filter-csv-by-terms infile outfile term [max rows]")
  Process.exit
end
infilename = ARGV[0]
outfilename = ARGV[1]
matchterms =  ARGV[2].split('&')  # split search regex's on &. we must match all.

# File wrapper that converts \" to "" as it reads,
# Needed to parse Wikileaks cables.csv

class MyFile < File

  def gets(*args)
    line = super
    if line != nil
      line.gsub!('\\\\','')
      line.gsub!('\\"','""')
    end
    line
  end
end

# match against a list of terms, each of which is a regex
def textmatch(text, terms)
  terms.all? { |term| text =~ /#{term}/i }
end


# --------------------------------------- main ----------------------------------------
docs_read = 0
docs_written = 0

out = CSV.open(outfilename,"w")

infile_file = MyFile.open(infilename)
infile = CSV.new(infile_file)

out << ["id","created_date","reference_id","origin","classification","references","header","text"]

while row = infile.shift
  
  # scan each field for text
  rowcopy = row.dup
  while rowcopy.length > 0

    # if we find all terms, spit out the whole original row
    if textmatch(rowcopy[0],matchterms)
      out << row
      docs_written += 1
      break
    end
      
    rowcopy.shift
  end
  
  docs_read+=1
  
  if ARGV.length > 3 && docs_read >= ARGV[3].to_i
    break
  end
end

puts(docs_read.to_s + " documents read")
puts(docs_written.to_s + " documents written")