# > ruby client.rb
require 'terminal-display-colors'
require 'json'
require_relative 'textract'

def newline
  puts "\n"
end

def indent message
  "   #{message}"
end

def clear
  puts "\e[H\e[2J"
end

def pause
  sleep (0.5)
end

def print_flush message
  print message
  $stdout.flush
end

def putss message
  for i in 0..message.length
    print_flush message[i]
    sleep(0.02)
  end
  newline
end

# primary methods
def get_emails
  putss indent "--> Getting emails".yellow
  puts JSON.pretty_generate(@textract.emails).green
  newline
end

def get_people
  putss indent "--> Getting people".yellow
  puts JSON.pretty_generate(@textract.people).green
  newline
end

def get_peoples_emails
  putss indent "--> Getting people's emails".yellow
  puts JSON.pretty_generate(@textract.peoples_emails).green
  newline
end

def get_phone_numbers
  putss indent "--> Getting phone numbers".yellow
  puts JSON.pretty_generate(@textract.phones).green
  newline
end

def get_isbns
  putss indent "--> Getting ISBN's".yellow
  puts JSON.pretty_generate(@textract.isbns([], true)).green
  newline
end

# start client
clear
putss "Thanks for using textract..."
newline
pause

putss indent "--> Loading sample file".yellow
file = File.open('sample.txt')
text = file.read.force_encoding('UTF-8')

putss indent "--> Creating textract object".yellow
@textract = Textract.new(text)

newline
putss "Processing..."
newline
pause

# process
if ARGV.empty?
  get_emails
  get_people
  get_peoples_emails
  get_phone_numbers
  get_isbns
else
  ARGV.each do |method|
    send method
  end
end

# done
putss "Complete!"
newline
newline