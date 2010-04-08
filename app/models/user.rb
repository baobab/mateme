require 'digest/sha1'

class User < ActiveRecord::Base
  include Openmrs
  set_table_name :users
  set_primary_key :user_id

  cattr_accessor :current_user
  attr_accessor :plain_password

  has_many :user_properties, :foreign_key => :user_id
  has_many :user_roles, :foreign_key => :user_id, :dependent => :delete_all

  def name
    #self.first_name + " " + self.last_name
    Person.find(self.user_id).name.titleize
  end
    
  def before_create    
    self.salt = User.random_string(10) if !self.salt?
    self.password = encrypt(self.password, self.salt) #if self.plain_password
  end
   
  def self.authenticate(login, password)
    u = find :first, :conditions => {:username => login} 
    u && u.authenticated?(password) ? u : nil
    #raise password
  end
      
  def authenticated?(plain)
  #  raise "#{plain} #{password} #{encrypt(plain, salt)} #{salt} :  #{Digest::SHA1.hexdigest(plain+salt)} : #{self.salt}"
    #raise "#{self.salt}"
    encrypt(plain, salt) == password || Digest::SHA1.hexdigest("#{plain}#{salt}") == password
  end
  
  def admin?
    user_roles.map{|user_role| user_role.role }.include? 'Informatics Manager'
  end  
      
  # Encrypts plain data with the salt.
  # Digest::SHA1.hexdigest("#{plain}#{salt}") would be equivalent to
  # MySQL SHA1 method, however OpenMRS uses a custom hex encoding which drops
  # Leading zeroes
  def encrypt(plain, salt)
    encoding = ""
    digest = Digest::SHA1.digest("#{plain}#{salt}") 
    (0..digest.size-1).each{|i| encoding << digest[i].to_s(16) }
    encoding
  end  

   def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

 end
