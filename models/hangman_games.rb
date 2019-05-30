# frozen_string_literal: true

# Shared methods between all individual games of hangman
class Hangman
  def initialize(midgame_data)
    @mistakes = midgame_data['mistakes'] || 0
    @guesses = midgame_data['guesses'] || []
    @shh_word = midgame_data['shh_word']
  end

  def draw_hanging
    return if @mistakes.zero?

    up = @mistakes >= 2 ? ' | ' : ''
    puts @mistakes >= 3 ? '  ___' : ''
    puts up + (@mistakes >= 4 ? ' o' : '')
    puts up + ['', ' |', '/|', '/|\\'][[[3, @mistakes - 4].min, 0].max]
    puts up + (@mistakes >= 8 ? ['/', '/ \\'][@mistakes - 8] : '')
    puts @mistakes == 1 ? '______' : '_|____'
  end

  def print_clue
    print 'Clue: '
    @shh_word.split('').each do |letter|
      print "#{@guesses.include?(letter) ? letter : '_'} "
    end
    puts
  end

  def print_guesses
    return if @guesses.empty?

    print 'Guesses: '
    @guesses.each { |guess| print "#{guess} " }
    puts
  end

  private

  def save_game
    {
      mistakes: @mistakes,
      guesses: @guesses,
      shh_word: @shh_word
    }
  end
end

# Methods shared by gametypes where a user guesses the secret word
class UserGuess < Hangman
  def guess(who)
    ins = get_guess(who)
    return save_game if ins =~ /(save|close)/

    ins = ins[0]
    if @guesses.include?(ins)
      puts "You already guessed '#{ins}'!"
      return user_guess(who)
    end
    @mistakes += 1 unless /#{ins}/.match(@shh_word)
    @guesses << ins
    false
  end

  def game_over?(who)
    if @shh_word.split('').uniq.all? { |l| @guesses.include?(l) }
      puts "You win, #{who}!"
      puts "The secret word was #{@shh_word}."
      'stayed'
    elsif @mistakes == 9
      puts "Oh no, #{who}! Too many mistakes. :("
      puts "The secret word was #{@shh_word}."
      'hanged'
    else false
    end
  end

  private

  def get_guess(who)
    puts "#{who}, guess a new letter. Or save and close game."
    ins = gets.strip
    ins =~ /^[a-zA-Z]/ ? ins.downcase : get_guess(who)
  end
end

# Controls game in which one player guesses the other's secret word
class PvP < UserGuess
  require 'io/console'

  def choose_secret_word(who)
    loop do
      puts "#{who}, enter your secret word."
      @shh_word = STDIN.noecho(&:gets).chomp.downcase
      if in_dictionary?
        puts "That'll do nicely. :)"
        break
      end
      puts "#{@shh_word} isn't in my dictionary."
      @shh_word = nil
    end
  end

  def in_dictionary?
    File.open('dictionary.txt').each_line.any? do |l|
      l.downcase == "#{@shh_word}\n"
    end
  end
end

# Contols game in which user guesses computer's randomly chosen secret word
class AIFollow < UserGuess
  def choose_secret_word(_randomly)
    @shh_word = File.readlines('dictionary.txt').keep_if do |line|
      line.length > 3 # Words < 4 letters are impossible, even w/ perfect play
    end.sample.strip.downcase
  end
end

# Controls game where user chooses word and AI guesses it
class AILead < Hangman
  def initialize(midgame_data)
    @mistakes = midgame_data['mistakes'] || 0
    @guesses = midgame_data['guesses'] || []
    @shh_word = midgame_data['shh_word']
    @poss = midgame_data['poss']
    @last_guess = midgame_data['last_guess']
    @game_over = false
    remind_user if @poss
  end

  def choose_secret_word(who)
    1.times do
      print "#{who}, pick a secret word and remember it. "
      puts 'How many letters are in it?'
      ins = gets.strip
      redo unless ins =~ /^\d+$/
      @shh_word = Array.new(ins.to_i)
    end
    create_initial_possibilities
  end

  def print_clue
    @shh_word.each { |letter| print "#{letter || '_'} " }
    puts
  end

  def guess(_computer)
    @last_guess = commonest_unused_letter(@poss.empty? ? all_words : @poss)
    # elsif only a few spaces left Look for patterns in feedback & match
    @guesses << @last_guess
    tell_user
    save_data = feedback
    save_data.is_a?(Hash) ? save_data : false
  end

  def game_over?(_computer)
    if @game_over
      puts 'Computer wins!'
      puts "The secret word was #{@shh_word.join('')}."
      'stayed'
    elsif @mistakes == 9
      puts 'You win! The computer made too many mistakes.'
      puts 'What was your secret word?'
      secret_word_consistant? ? 'hanged' : 'stayed'
    else false
    end
  end

  private

  def remind_user
    print_clue
    print_guesses
    puts "I guessed #{@last_guess}..."
    feedback
  end

  def create_initial_possibilities
    key_length = @shh_word.length + 1
    @poss = File.readlines('dictionary.txt').map do |l|
      l.strip.downcase if l.length == key_length
    end.compact
  end

  def all_words
    File.readlines('dictionary.txt').map { |l| l.strip.downcase }
  end

  def commonest_unused_letter(words)
    letter_freqs = Array.new(52) { |i| i.even? ? (i / 2 + 97).chr : 0 }
    letter_freqs = Hash[*letter_freqs]
    words.each do |word|
      word.split('').uniq.each { |letter| letter_freqs[letter] += 1 }
    end
    letter_freqs.max_by { |k, v| @guesses.include?(k) ? 0 : v }[0]
  end

  def tell_user
    print 'Let me think'
    3.times do
      sleep 0.6
      print '.'
    end
    puts "\n#{@last_guess}"
  end

  def feedback(verbose = false)
    nums = get_fb(verbose)
    return nums if nums.is_a? Hash

    nums.each { |i| @shh_word[i] = @last_guess }
    return @game_over = true if @shh_word.all?

    @poss.keep_if do |w|
      (0...w.length).all? { |i| nums.include?(i) ^ (w[i] != @last_guess) }
    end
  end

  def get_fb(verbose = false)
    if verbose
      puts "Enter the position of each '#{@last_guess}' in your secret word."
      puts "For example, '2 4' if the word was 'seven' and the guess was 'e'."
      puts 'If the guess is wrong, just press enter.'
    else puts "Where does '#{@last_guess}' occur? ('h' for help; 's' to save.)"
    end
    ins = gets
    return get_fb(true) if ins =~ /[hH]/

    return save_game if ins =~ /[sScC]/

    parse_fb(ins)
  end

  def parse_fb(ins)
    nums = ins.scan(/\d+/)
    if nums.empty?
      @mistakes += 1
      return nums
    end
    nums.map! { |c| c.to_i - 1 }.uniq!
    if nums.any? { |i| i >= @shh_word.length || @shh_word[i] }
      get_fb(true)
    else nums
    end
  end

  def save_game
    save_data = super()
    save_data[:poss] = @poss
    save_data[:last_guess] = @last_guess
    save_data
  end

  def secret_word_consistant?
    ins = gets.strip
    !(incorrect_length?(ins) || false_acceptance(ins) || false_denial?(ins))
  end

  def false_acceptance(ins)
    acc_chars = @shh_word.each_with_index.inject([]) do |chars, (l, i)|
      l && ins[i] != l ? chars << [ins[i], l] : chars
    end
    return false if acc_chars.empty?

    print 'Hey! You said'
    acc_chars.each { |(actual, told)| print " '#{actual}' was '#{told}', and" }
    puts "\b\b\b\b\b!"
    true
  end

  def incorrect_length?(ins)
    return false if ins.length == @shh_word.length

    puts "Hey! You said it had #{@shh_word.length} letters, "\
      "but #{ins} has #{ins.length}."
    true
  end

  def false_denial?(ins)
    denied_chars = @shh_word.each_with_index.inject([]) do |chars, (l, i)|
      l ? chars : chars << ins[i]
    end.uniq
    false_denials = denied_chars.select { |letter| @guesses.include?(letter) }
    return false if false_denials.empty?

    shout_about(false_denials)
    true
  end

  def shout_about(false_denials)
    print 'Hey! You said there were no'
    if false_denials.length > 1
      (0...false_denials.length - 1).to_a.each { |l| print " #{l}'s," }
      print ' or'
    end
    puts " #{false_denials.last}'s!"
  end
end

#   ___
#  |  o
#  | /|\
#  | / \
# _|____
#   ___
#  |  |
#  |
#  |
# _|____
