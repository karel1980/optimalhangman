
require 'zlib'

class HangmanGame
  def initialize(word)
    @word=word
  end

  def word_length()
    @word.length
  end

  def letter_positions(letter)
    result = []
    pos = @word.index(letter)
    while ! pos.nil?
      result << pos
      pos = @word.index(letter, pos+1)
    end
    return result
  end
end

class OptimalHangmanPlayer
  def initialize(wordlist)
    @wordlist=wordlist
  end 

  def play(game, verbose=false)
    known_chars = Array.new game.word_length
    misses = []
    guess_count = 0

    keep_trying = true
    while known_chars.include?(nil) and keep_trying:
      keep_trying = false
      guesses = next_guesses known_chars, misses
      puts "My next guesses are #{guesses}" if verbose
      guesses.each do |guess|
        positions = game.letter_positions(guess)
        guess_count += 1
        if positions.length == 0 then
          puts "Tried #{guess}: (miss) #{known_chars.map { |c| c.nil? ? "." : c}}" if verbose
          misses << guess
        else
          puts "Tried #{guess}: (hit)  #{known_chars.map { |c| c.nil? ? "." : c}}" if verbose
          positions.each do |pos|
            known_chars[pos]=guess
          end
          keep_trying = true
          break
        end
      end
    end
    if known_chars.include?(nil) then
      puts "Didn't find it, last was #{known_chars}" if verbose
    else
      puts "Found it in #{guess_count} tries and with #{misses.size} miss(es): #{known_chars}" if verbose
    end
    return [guess_count, misses.size()]
  end

  def next_guesses(known, misses)
    occ = occurrences known, misses
    return occ.sort_by { |k,v| -v }.map { |pair| pair[0] } - known
  end

  def occurrences(known, misses)
    result = Hash.new 0
    must_match = pattern_for_known known
    may_not_match = pattern_for_misses misses
    @wordlist.each do |word|
      if must_match.match(word) and (may_not_match.nil? or !may_not_match.match(word)) then
        word.each_char do |char|
          result[char] += 1
        end
      end
    end
    return result
  end

  def pattern_for_known(known)
    return Regexp.new "^" + known.map { |c| c.nil? ? "." : c }.join("") + "$"
  end

  def pattern_for_misses(misses)
    if misses.empty? then
      nil
    else
      Regexp.new "[" + misses.join("") + "]"
    end
  end
end

def load_words(dictfile)
  $stderr.puts "Reading dictionary..."
  gz = Zlib::GzipReader.new(File.new dictfile) 
  wordlist = gz.read.split("\n")
  wordlist.map! do |word|
    word.downcase!
    word.gsub!(/[^a-z]/, "")
  end
  $stderr.puts "done."
  return wordlist
end

def print_misses_per_word(wordlist, player)
  wordlist.each do |word|
    puts "#{player.play(HangmanGame.new word)[1]} #{word}"
  end
end

def usage()
  puts "usage: see README.md"
end

wordlist = load_words('english.txt.gz')
case ARGV[0]
  when nil
    usage
  when "play"
    if ARGV[1].nil? then
      puts "Missing argument"
      usage
    else
      player = OptimalHangmanPlayer.new wordlist
      game = HangmanGame.new ARGV[1]
      player.play game, true

    end
  when "print_misses_per_word"
    player = OptimalHangmanPlayer.new wordlist
    print_misses_per_word(wordlist, player)
end