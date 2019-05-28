# Underline first letter of string
class String
  def underline_first
    capitalize!
    "\e[4m#{self[0]}\e[0m#{self[1..-1]}"
  end
end
