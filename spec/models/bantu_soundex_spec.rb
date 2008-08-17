require File.dirname(__FILE__) + '/../spec_helper'

describe "Soundex" do
  it "should be able to convert a word to code" do
    "Rodney".soundex.should_not be_nil
  end  
  
  it "should capatalize all of the letters" do
    "x".soundex.should == "X000"
  end
  
  it "should drop all of the punctuation marks" do
    "kg'g".soundex.should == "K200"    
  end
  
  it "should convert vowels, 'H', 'W', and 'Y' before it removes double letters" do
    "kghg".soundex.should == "K220"    
    "kgwg".soundex.should == "K220"    
    "kgyg".soundex.should == "K220"        
  end
  
  it "should convert consonants to the correct group" do
    "XL".soundex.should == "X400"    
    "XR".soundex.should == "X400"    
  end
  
  it "should remove double letters" do
    "XLL".soundex.should == "X400"    
    "XLR".soundex.should == "X400"    
  end  
  
  it "should remove vowels" do
    "KAEI".soundex.should == "K000"    
    "KOUW".soundex.should == "K000"    
    "KHAY".soundex.should == "K000"    
  end  
  
  it "should construct the code from the first letter and first three digits" do
    "KOWALE".soundex.should == "K840"        
  end

  it "should append '0' to the code if there are not enough digits" do
    "G".soundex.should == "G000" 
  end

  it "should maintain the first letter of the word unless it is a 'N', 'M', or 'D' followed by a consonant" do
    "DZANJALIMODZI".soundex.should == "Z574"    
    "MZIMBA".soundex.should == "Z510"    
    "NGOMBE".soundex.should == "G510"    
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
    "CHICHEWA".soundex.should == "9980"
    "BWAIWLA".soundex.should == "B840"
  end
  
  it "should encode 'CH', 'TCH', and 'THY' as a separate consonant class" do
    "KCH".soundex.should == "K900"
    "KTHY".soundex.should == "K900"
    "KTCH".soundex.should == "K900"
    "THYOLO".soundex.should == "9400"
  end
  
  it "should encode initial 'C' as a 'K'" do
    "CAUMA".soundex.should == "K500"
  end
  
  it "should encode initial 'A' and 'I' as 'E'" do
    "EVAN".soundex.should == "E150"
    "AVAN".soundex.should == "E150"
    "IVAN".soundex.should == "E150"
  end
    
end
