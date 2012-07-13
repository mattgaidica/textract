require 'stanford-core-nlp'
require 'amatch'
include Amatch

class Textract
  attr_accessor :text
  def initialize text
    @text = text.force_encoding('UTF-8')
  end

  def all
    # since telephone regex is more strict, remove duplicates
    books = self.books
    # no need, but for the future string.scan(/\d+/).join to remove all but numbers
    phones = self.phones
    books.delete_if {|x| phones.include?(x)}

    {
      :books => books,
      :phones => phones,
      :emails => self.emails
    }
  end

  def people
    emails = self.emails
    pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
    text = StanfordCoreNLP::Text.new(@text)
    pipeline.annotate(text)

    entities = []
    text.get(:sentences).each do |sentence|
      # Syntatical dependencies
      #puts sentence.get(:basic_dependencies).to_s
      sentence.get(:tokens).each do |token|
        entity = token.get(:named_entity_tag).to_s
        if entity.downcase.eql?('person')
          entities << {
            :entity => entity.downcase,
            :value => token.get(:value).to_s,
            :start => token.get(:character_offset_begin).to_s.to_i,
            :end => token.get(:character_offset_end).to_s.to_i
          }
        end
      end
    end

    last_pos = nil
    buffer = ''
    temp = []

    entities.each_with_index do |entry, i|
      if last_pos.nil? #first round
        buffer << entry[:value]
      else
        # are the entries 1 character away? is that character a space?
        # puts "start minus last pos: #{(entry[:start] - last_pos)}"
        # puts "raw text: #{@text.slice(last_pos)}"
        # puts "last_pos: #{last_pos}"
        if (entry[:start] - last_pos) == 1 && @text.slice(last_pos).eql?(' ')
          buffer << " #{entry[:value]}"
        else
          #is there a word after it?
          #is the next sequence a space and a capitalized letter?
          # -> add it to buffer as name
          temp << buffer
          buffer = entry[:value]
        end
      end
      last_pos = entry[:end]
    end
    temp << buffer
    temp.uniq
  end

  def peoples_emails people=nil, emails=nil
    emails = self.emails unless emails
    people = self.people unless people

    email_rankings = []
    temp = {}
    emails.each do |email|
      people.each do |person|
        m = Levenshtein.new(email.split('@').first.downcase.scan(/[a-z]/).join(''))
        #could try averaging matches with just their initials, last name, etc.
        tests = []
        tests << m.match(person.downcase.scan(/[a-z]/).join(''))
        tests << m.match("#{person.split(' ').first.downcase[0]}#{person.split(' ').last.downcase[0]}")
        tests << m.match(person.split(' ').first.downcase)
        tests << m.match(person.split(' ').last.downcase)
        temp[person] = tests.min
      end
      email_rankings << temp.sort_by {|k,v| v}
      temp = {}
    end

    assignments = {}
    while(assignments.keys.count < [emails.count, people.count].min)
      email_rankings.each_with_index do |email_ranking, i|
        next if assignments.has_value?(emails[i]) #next if email is assigned
        email_ranking.each do |person_ranking|
          next if assignments.has_key?(person_ranking[0]) #next if name is assigned
          found_lower = false
          email_rankings.each_with_index do |email_ranking_temp, j|
            next if assignments.has_value?(emails[j]) #next if email is assigned
            email_ranking_temp.each do |person_ranking_temp|
              if person_ranking_temp[0] == person_ranking[0] && person_ranking_temp[1] < person_ranking[1]
                found_lower = true
              end
            end
          end
          if found_lower == false
            assignments[person_ranking[0]] = emails[i]
            break
          end
        end
      end
    end
    
    assignments
  end

  def isbns
    isbns = []
    self.text.scan(/(?<isbn>(\d[- ]?){9,12}([0-9xX]))/).each {|x| isbns << x[0]}
    isbns
  end

  def phones
    phones = []
    # comes out [prefix, XXX, XXX, XXXX, extension]
    self.text.scan(/\s(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?\s/).each do |x|
      phone = ""
      phone << "#{x[0]}-" unless x[0].nil?
      phone << "#{x[1]}-" unless x[1].nil?
      phone << "#{x[2]}-#{x[3]}"
      phone.gsub!(' ', '')
      phone << " x#{x[4]}" unless x[4].nil?
      phones << phone
    end
    phones
  end

  def emails
    emails = []
    self.text.scan(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).each {|x| emails << x}
    emails
  end
end