# Each score is hash of:
#   points -> max moves between a user decision and them losing (or nil); and
#   score -> ratio of [ai-wins : draws : user-wins] in a game-tree
class Scores < Array
  def normalise_scores
    map do |score|
      sum = score[:score].sum.to_f
      normed_score = { points: score[:points] }
      normed_score[:score] = score[:score].map { |x| x / sum }
      normed_score
    end
  end

  # Picks child with lowest chance of opponent win, else dead-cert, else highest
  # points, else lowest draw-rate. Returns child's index.
  def choose_wisely
    each_with_index.min do |(a_s, _i), (b_s, _j)|
      a_los = a_s[:score][2]
      loss_comp = a_los <=> b_s[:score][2]
      loss_comp.zero? ? compare_by_wins(a_s, b_s) : loss_comp
    end[1]
  end

  # Si is vector of score i; l = lowest common multiple of all ΣS.
  # A = Σ(Si * l / ΣSi); g = greatest common divisor of A
  # = G A / g
  def average_scores
    sums = map_to_score_sums
    l_c_m = sums.inject(1, :lcm)
    score = each_with_object([0, 0, 0]).with_index do |(s_score, arr), i|
      s_score[:score].each_with_index { |x, j| arr[j] += x * l_c_m / sums[i] }
    end
    g_c_d = score.inject(score[0], :gcd)
    score.map! { |x| x / g_c_d }
  end

  def max_points
    result = map { |score| score[:points] || 0 }.max
    result.zero? ? nil : result
  end

  private

  def compare_by_wins(a_s, b_s)
    return 1 if a_s[:score][0].zero?

    return -1 if b_s[:score][0].zero?

    compare_by_draws(a_s, b_s)
  end

  def compare_by_draws(a_s, b_s)
    a_draw_s = a_s[:score][1]
    b_draw_s = b_s[:score][1]
    return (b_draw_s.zero? ? compare_points(a_s, b_s) : -1) if a_draw_s.zero?

    return 1 if b_draw_s.zero?

    point_comp = compare_points(a_s, b_s, true)
    point_comp.zero? ? a_draw_s <=> b_draw_s : point_comp
  end

  # Spaceship comparison of gamestates' points. Swap if scores include draws
  def compare_points(a_s, b_s, swap = false)
    ((a_s[:points] || 0) <=> (b_s[:points] || 0)) * (swap ? -1 : 1)
  end

  def map_to_score_sums
    map { |score| score[:score].sum }
  end

  def map(&block)
    dup.map!(&block)
  end
end
