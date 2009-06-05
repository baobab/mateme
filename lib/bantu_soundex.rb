# QUESTION: Should double letters at the beginning of the word be removed? For example: LLAMA. Is there a Chichewa example of this?
# QUESTION: Should prefixes be dropped, for example "wa" in Bingu wa Mutharinka, "ma" in Maganga
# This soundex algorithm uses the modified soundex from http://www.creativyst.com/Doc/Articles/SoundEx1/SoundEx1.htm
# We also modified it further to support common chichewa word beginnings and match 'L' and 'R'
class String  
  def soundex
    # Grab a temporary copy of the word
    word = "#{self}"    
    # Handle blanks
    return nil if word.blank?  
    # Capitalize all letters in the word
    word.upcase!
    # Drop all punctuation marks and numbers and spaces
    word.gsub!(/[^A-Z]/, '')    
    return nil if word.blank?  
    # Words starting with M or N or D followed by another consonant should drop the first letter
    word.gsub!(/^M([BDFGJKLMNPQRSTVXZ])/, '\1') 
    word.gsub!(/^N([BCDFGJKLMNPQRSTVXZ])/, '\1')
    word.gsub!(/^D([BCDFGJKLMNPQRSTVXZ])/, '\1')
    # THY and CH as common phonemes enhancement
    word.gsub!(/(THY|CH|TCH)/, '9')    
    # Retain the first letter of the word
    initial = word.slice(0..0)
    tail = word.slice(1..word.size)
    # Initial vowel enhancement
    initial.gsub!(/[AEI]/, 'E')
    # Initial C/K enhancement
    initial.gsub!(/[CK]/, 'K')    
    initial.gsub!(/[JY]/, 'Y')    
    initial.gsub!(/[VF]/, 'F')    
    initial.gsub!(/[LR]/, 'R')
    initial.gsub!(/[MN]/, 'N')
    initial.gsub!(/[SZ]/, 'Z') 
    # W followed by a vowel should be treated as a consonant enhancement
    tail.gsub!(/W[AEIOUHY]/, '8')
    # Change letters from the following sets into the digit given
    tail.gsub!(/[AEIOUHWY]/, '0')
    tail.gsub!(/[BFPV]/, '1')
    tail.gsub!(/[CGKQX]/, '2') 
    tail.gsub!(/[DT]/, '3')
    tail.gsub!(/[LR]/, '4')
    tail.gsub!(/[MN]/, '5')
    tail.gsub!(/[SZ]/, '6') # Originally with CGKQX
    tail.gsub!(/[J]/, '7') # Originally with CGKQX
    # Remove all pairs of digits which occur beside each other from the string
    tail.gsub!(/1+/, '1')
    tail.gsub!(/2+/, '2')
    tail.gsub!(/3+/, '3')
    tail.gsub!(/4+/, '4')
    tail.gsub!(/5+/, '5')
    tail.gsub!(/6+/, '6')
    tail.gsub!(/7+/, '7')
    tail.gsub!(/8+/, '8')
    tail.gsub!(/9+/, '9')
    # Remove all zeros from the string
    tail.gsub!(/0/, '')
    # Return only the first four positions
    initial + tail.slice(0..2)
  end
end