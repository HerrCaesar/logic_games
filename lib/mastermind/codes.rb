# Array of all possibles codes in a mastermind game
class Codes < Array
  attr_reader :first_imposs
  def initialize(_par = 0)
    super
  end

  def full
    @first_imposs = length
    self
  end

  def most_instructive(possibles = self[0...@first_imposs])
    smallest_common_cattle(map { |code| [code] << code.herd_cattle(possibles) })
  end

  def sort_by_cattle!(the_guess, cattle)
    poss_and_imposs = self[0...@first_imposs].each do |code|
      code.compare_cattle(the_guess, cattle)
    end.group_by(&:possible?)
    self[0...@first_imposs] = poss_and_imposs[true] + poss_and_imposs[false]
    @first_imposs = poss_and_imposs[true].length
    self
  end

  private

  def smallest_common_cattle(codes_with_group_sizes)
    codes_with_group_sizes.min do |(a, grp_szs_a), (b, grp_szs_b)|
      ship = n = 0
      while ship.zero?
        ship = (grp_szs_a.max(n + 1)[n] || (a.possible? ? 0 : 2)) <=>
               (grp_szs_b.max(n + 1)[n] || (b.possible? ? 1 : 3))
        n += 1
      end
      ship
    end[0]
  end
end
