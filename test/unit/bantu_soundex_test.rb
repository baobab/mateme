require File.dirname(__FILE__) + '/../test_helper'

class BantuSoundexTest < ActiveSupport::TestCase 
  context "Soundex" do
    should "be able to convert a word to code" do
      assert_not_nil "Rodney".soundex
    end  
    
    should "capatalize all of the letters" do
      assert_equal "x".soundex, "X"
    end
    
    should "drop all of the punctuation marks" do
      assert_equal "kg'g".soundex, "K2"    
    end
    
    should "convert vowels, 'H', 'W', and 'Y' before it removes double letters" do
      assert_equal "kghg".soundex, "K22"    
      assert_equal "kgwg".soundex, "K22"    
      assert_equal "kgyg".soundex, "K22"        
    end
    
    should "convert consonants to the correct group" do
      assert_equal "XL".soundex, "X4"    
      assert_equal "XR".soundex, "X4"    
    end
    
    should "remove double letters" do
      assert_equal "XLL".soundex, "X4"    
      assert_equal "XLR".soundex, "X4"    
    end  
    
    should "remove vowels" do
      assert_equal "KAEI".soundex, "K"    
      assert_equal "KOUW".soundex, "K"    
      assert_equal "KHAY".soundex, "K"    
    end  
    
    should "construct the code from the first letter and first three digits" do
      assert_equal "KOWALE".soundex, "K84"        
    end

    should "maintain the first letter of the word unless it is a 'N', 'M', or 'D' followed by a consonant" do
      assert_equal "DZANJALIMODZI".soundex, "Z574"    
      assert_equal "MZIMBA".soundex, "Z51"    
      assert_equal "NGOMBE".soundex, "G51"    
    end
    
    should "return nil for blank strings" do
      assert_nil "".soundex
    end
    
    should "return nil for strings with no letters" do
      assert_nil "1234".soundex
      assert_nil " ".soundex
      assert_nil "-".soundex
    end
    
    should "encode 'W' followed by a vowel as a separate consonant class" do
      assert_equal "CHICHEWA".soundex, "998"
      assert_equal "BWAIWLA".soundex, "B84"
    end
    
    should "encode 'CH', 'TCH', and 'THY' as a separate consonant class" do
      assert_equal "KCH".soundex, "K9"
      assert_equal "KTHY".soundex, "K9"
      assert_equal "KTCH".soundex, "K9"
      assert_equal "THYOLO".soundex, "94"
    end
    
    should "encode initial 'C' as a 'K'" do
      assert_equal "CAUMA".soundex, "K5"
    end
    
    should "encode initial 'A' and 'I' as 'E'" do
      assert_equal "EVAN".soundex, "E15"
      assert_equal "AVAN".soundex, "E15"
      assert_equal "IVAN".soundex, "E15"
    end      
  end
end