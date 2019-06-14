# Each score is ratio of [ai-wins, draws, user-wins] in a game-tree
class Scores < Array
  def normalise_scores
    map do |score|
      sum = score.sum.to_f
      norm_score = score.map { |x| x / sum }
      norm_score
    end
  end

  # Sorts childrens' value by least chance of opponent win, then draw, else left
  def choose_wisely
    each_with_index.min do |(a, _i), (b, _j)|
      spaceship = 0
      n = 2
      while spaceship.zero?
        spaceship = if n > 0
                      a[n] <=> b[n]
                    else -1
                    end
        n -= 1
      end
      spaceship
    end[1]
  end

  # Si is vector of score i; l = lowest common multiple of all ΣS.
  # A = Σ(Si * l / ΣSi); g = greatest common divisor of A
  # = G A / g
  def average_scores
    sums = map(&:sum)
    l_c_m = sums.inject(1, :lcm)
    score = each_with_object([0, 0, 0]).with_index do |(s_score, arr), i|
      s_score.each_with_index { |x, j| arr[j] += x * l_c_m / sums[i] }
    end
    g_c_d = score.inject(score[0], :gcd)
    score.map! { |x| x / g_c_d }
  end

  private

  def map(&block)
    dup.map!(&block)
  end
end
