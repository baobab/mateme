require File.dirname(__FILE__) + '/../spec_helper'

describe "Soundex" do
  it "should be able to convert a word to code" do
    "Rodney".soundex.should_not be_nil
  end  
  
  it "should capatalize all of the letters" do
    "x".soundex.should == "X"
  end
  
  it "should drop all of the punctuation marks" do
    "kg'g".soundex.should == "K2"    
  end
  
  it "should convert vowels, 'H', 'W', and 'Y' before it removes double letters" do
    "kghg".soundex.should == "K22"    
    "kgwg".soundex.should == "K22"    
    "kgyg".soundex.should == "K22"        
  end
  
  it "should convert consonants to the correct group" do
    "XL".soundex.should == "X4"    
    "XR".soundex.should == "X4"    
  end
  
  it "should remove double letters" do
    "XLL".soundex.should == "X4"    
    "XLR".soundex.should == "X4"    
  end  
  
  it "should remove vowels" do
    "KAEI".soundex.should == "K"    
    "KOUW".soundex.should == "K"    
    "KHAY".soundex.should == "K"    
  end  
  
  it "should construct the code from the first letter and first three digits" do
    "KOWALE".soundex.should == "K84"        
  end

  it "should maintain the first letter of the word unless it is a 'N', 'M', or 'D' followed by a consonant" do
    "DZANJALIMODZI".soundex.should == "Z574"    
    "MZIMBA".soundex.should == "Z51"    
    "NGOMBE".soundex.should == "G51"    
  end
  
  it "should return nil for blank strings" do
    "".soundex.should be_nil
  end
  
  it "should return nil for strings with no letters" do
    "1234".soundex.should be_nil
    " ".soundex.should be_nil
    "-".soundex.should be_nil
  end
  
  it "should encode 'W' followed by a vowel as a separate consonant class" do
    "CHICHEWA".soundex.should == "998"
    "BWAIWLA".soundex.should == "B84"
  end
  
  it "should encode 'CH', 'TCH', and 'THY' as a separate consonant class" do
    "KCH".soundex.should == "K9"
    "KTHY".soundex.should == "K9"
    "KTCH".soundex.should == "K9"
    "THYOLO".soundex.should == "94"
  end
  
  it "should encode initial 'C' as a 'K'" do
    "CAUMA".soundex.should == "K5"
  end
  
  it "should encode initial 'A' and 'I' as 'E'" do
    "EVAN".soundex.should == "E15"
    "AVAN".soundex.should == "E15"
    "IVAN".soundex.should == "E15"
  end
    
end
