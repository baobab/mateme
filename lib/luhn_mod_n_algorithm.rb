# http://en.wikipedia.org/wiki/Luhn_mod_N_algorithm
class LuhnModNAlgorithm

  # Valid characters is expected to be an array such as ['0', '1', '2' ... 'a']
  def initialize(valid_characters)
    @valid_characters = valid_characters
  end

  def generate_check_character(input)
    factor = 2
    sum = 0
    n = @valid_characters.length

    # Starting from the right and working leftwards is easier since 
    # the initial "factor" will always be "2" 
    characters = input.split(//).reverse
    characters.each{|char|
      # Use the position in the array as code point instead of ascii values
      code_point = @valid_characters.index(char)
      addend = factor * code_point
      # Alternate the "factor" that each "code point" is multiplied by
      factor = (factor == 2) ? 1 : 2
      # Sum the digits of the "addend" as expressed in base "n"
      addend = (addend / n) + (addend % n)
      sum += addend
    }   
    # Calculate the number that must be added to the "sum" 
    # to make it divisible by "n"
    remainder = sum % n
    check_code_point = n - remainder
    check_code_point %= n   
    @valid_characters[check_code_point]
  end
  
  def validate_check_character(input)
    factor = 1
    sum = 0
    n = @valid_characters.length

    # Starting from the right and working leftwards is easier since 
    # the initial "factor" will always be "2" 
    characters = input.split(//).reverse
    characters.each{|char|
      # Use the position in the array as code point instead of ascii values
      code_point = @valid_characters.index(char)
      addend = factor * code_point
      # Alternate the "factor" that each "code point" is multiplied by
      factor = (factor == 2) ? 1 : 2
      # Sum the digits of the "addend" as expressed in base "n"
      addend = (addend / n) + (addend % n)
      sum += addend
    }   
    remainder = sum % n
    remainder == 0
  end

end
