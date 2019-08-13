

class Papa
  def fun
    puts @var
  end
end

class Kid < Papa
  def initialize
    @var = 'hi'.freeze
  end
end

Kid.new.fun
