# Introduction

A simple program for experimenting with Hangman strategies
* inspired by http://www.datagenetics.com/blog/april12012/index.html

Note: the word list (english.txt) is taken from http://wordlist.sourceforge.net (scowl)

# Usage

Show the optimal strategy for finding 'strawberry':

    ruby hangman.rb play strawberry

Generate a list of words, prepended with the number of misses when following the optimal strategy. Sort with sort -n to find the easiest / most difficult words to guess with hangman.

    ruby hangman.rb print_misses_per_word

Needless to say, I challenge you, the reader, to come up with a better strategy ;)
There are different ways to evaluate hangman strategies. The most relevant evaluation method is to count the number of words the strategy can guess using < N 'misses' (i.e. where >= N means you lose the game)

# Bugs

* Wordlist cleanup simply drops accents, symbols, ...
* Wordlist contains non-words: e.g. 'a','b','c','d', ...'z' (only a and i are words)
  (this makes it very difficult to guess 'a', even though it should take at most 2 guesses)
* misses_per_word is very slow implementation at the moment, it recalculates the same information over and over (should be recursive etc...)