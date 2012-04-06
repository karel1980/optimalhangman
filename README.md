# Introduction

A simple program for experimenting with Hangman strategies
* inspired by http://www.datagenetics.com/blog/april12012/index.html

Note: the word list (english.txt) is taken from http://wordlist.sourceforge.net (scowl)

# Usage

Show how the optimal strategy guesses 'strawberry':

    ruby hangman.rb play english.txt.gz strawberry

The following command prints the number of 'misses' the optimal strategy uses before guessing the word:

    ruby hangman.rb score english.txt.gz

# Bugs

* Need a better wordlist: the english Wordlist contains non-words: e.g. 'a','b','c','d', ...'z' (only a and i are words) -> this makes 'a' the most difficult word, instead finding it right away
* To make things simpler, letters with accents and symbols are simply dropped. This introduces a couple of non-existing words of course.

