
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
    remaining_words = @wordlist.find_all { |w| w.length == game.word_length }
    while known_chars.include?(nil) and keep_trying:
      keep_trying = false
      freq = letter_frequencies(remaining_words)
      guesses = next_guesses(freq, known_chars)
      puts "Remaining dictionary size: #{remaining_words.size}" if verbose
      puts "My next guesses are #{guesses}" if verbose
      guesses.each do |guess|
        positions = game.letter_positions(guess)
        guess_count += 1
        if positions.length == 0 then
          puts "Tried #{guess}: (miss) #{known_chars.map { |c| c.nil? ? "." : c}}" if verbose
          misses << guess
          p = pattern_for_misses misses
          remaining_words = remaining_words.find_all { |w| !p.match(w) }
        else
          puts "Tried #{guess}: (hit)  #{known_chars.map { |c| c.nil? ? "." : c}}" if verbose
          positions.each do |pos|
            known_chars[pos]=guess
          end
          p = pattern_for_known known_chars
          remaining_words = remaining_words.find_all { |w| p.match(w) }
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

def letter_frequencies(wordlist)
  result = Hash.new 0
  wordlist.each do |word|
    word.each_char do |char|
      result[char] += 1
    end
  end
  return result
end

def next_guesses(frequencies, known_chars)
  return frequencies.sort_by { |k,v| -v }.map { |pair| pair[0] } - known_chars
end

def load_words(dictfile)
  $stderr.puts "Reading dictionary..."
  gz = Zlib::GzipReader.new(File.new dictfile) 
  wordlist = gz.readlines.map! do |word|
    word.downcase!
    word.gsub!(/[^a-z]/, "")
  end
  $stderr.puts "done. #{wordlist.size} words."
  return wordlist
end

def print_misses_per_word(wordlist, player)
  by_length=wordlist.group_by{|w|w.length}
  by_length.each{|l,words|
    misses=[]
    known_chars=[]
    recursive_next_guess(words, misses, known_chars)
  }
end

def recursive_next_guess(words, misses, known_chars)
  #puts "-------------------"
  #puts "# remaining/misses/known: #{words.size}/#{misses}/#{known_chars}"
  return if words.size == 0
  #puts words.join(",")
  # remove found words
  complete_words = words.find_all do |w|
    notguesses = w.split(//) - known_chars
    notguesses.size == 0
  end
  complete_words.each do |w|
    puts "#{misses.size} #{w}"
  end
  #puts "# complete words: #{complete_words.size}"
  words = words - complete_words
  return if words.size == 0
  #puts "# remaining unguesses words: #{words.size}"
  freq = letter_frequencies(words)
  guesses = next_guesses(freq, known_chars)
  #puts "next guess: #{guesses[0]}"
  if guesses.size == 0 then
    #puts "exhausted for #{words.join(",")}"
  else
    guess = guesses[0]

    matching = words.find_all{|w| w.index(guess)}
    known_chars << guess
    recursive_next_guess(matching, misses, known_chars)
    known_chars.delete guess

    non_matching = words.find_all{|w| !w.index(guess)}
    misses << guess
    recursive_next_guess(non_matching, misses, known_chars)
    misses.delete guess
  end
end

def usage()
  puts "usage: see README.md"
end

wordlist = load_words('dutch.txt.gz').find_all { |w| !w.nil? }
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
