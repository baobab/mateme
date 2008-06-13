require 'digest/sha1'

class User < ActiveRecord::Base
  include Openmrs

  cattr_accessor :current_user

  set_table_name "users"
  validates_presence_of:username,:password, :message =>"Fill in Username"
  validates_length_of:username, :within => 4..20
  validates_uniqueness_of:username
 #validates_length_of:password, :within => 4..50
  
  has_many :user_properties, :foreign_key => :user_id
  has_many :user_roles, :foreign_key => :user_id, :dependent => :delete_all
  has_many :roles, :through => :user_roles, :foreign_key => :user_id
  
  has_one :activities_property, 
          :class_name => 'UserProperty',
          :foreign_key => :user_id,
          :conditions => ['property = ?', 'Activities']

#user_id
  set_primary_key "user_id"

  def name
    self.first_name + " " + self.last_name
  end
  
  def has_role(name)
    self.roles.each{|role|
      return true if role.role == name
    }
    return false
  end

  def has_privilege_by_name(privilege_name)
    self.has_privilege(Privilege.find_by_privilege(privilege_name))
  end
  
  def has_privilege(privilege)
    raise "has_privilege method expects privilege object not string, use has_privilege_by_name instead" if privilege.class == String
    self.roles.each{|role|
      role.privileges.each{|priv|
        return true if priv == privilege
      }
    }
    return false
  end

  def activities
    a = activities_property
    return [] unless a
    a.property_value.split(',')
  end

  # Should we eventually check that they cannot assign an activity they don't
  # have a corresponding privilege for?
  def activities=(arr)
    prop = activities_property || UserProperty.new    
    prop.property = 'Activities'
    prop.property_value = arr.join(',')
    prop.user_id = self.id
    prop.save
  end  

  def current_programs
    current_programs = Array.new
    current_programs << Program.find_by_name("HIV")
    current_programs << Program.find_by_name("Tuberculosis (TB)") unless self.activities.grep(/TB/).empty?
    return current_programs
  end

  def privileges
    self.roles.collect{|role|
      role.privileges
    }.flatten.uniq
  end

  def before_create
    super
    self.salt = User.random_string(10) if !self.salt?
    self.password = User.encrypt(self.password,self.salt) 
  end
  
  def before_update
    super
    self.salt = User.random_string(10) if !self.salt?
    self.password = User.encrypt(self.password,self.salt) 
  end

  # Encrypts some data with the salt.
  # Digest::SHA1.hexdigest("#{plain_password}#{salt}") would be equivalent to
  # MySQL SHA1 method, however OpenMRS uses a custom hex encoding which drops
  # Leading zeroes
  def self.encrypt(plain_password, salt)
    encoding = ""
    digest = Digest::SHA1.digest("#{plain_password}#{salt}") 
    (0..digest.size-1).each{|i|encoding << digest[i].to_s(16)}
    encoding
  end
   
  def after_create
    super
    @password=nil
  end
  
  def self.authenticate(username,password)
    @user = User.find(:first ,:conditions =>["username=? ", username])

    salt=@user.salt unless @user.nil?
    
    return nil if @user.nil?
    return @user if encrypt(password, salt) == @user.password || Digest::SHA1.hexdigest("#{password}#{salt}") == @user.password
  end 
  
  def try_to_login
    User.authenticate(self.username,self.password)
  end
  
  
  def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
  def self.setup_default_activities

# Available activites
# ["ART Visit", "Enter past visit", "Give drugs", "HIV First visit", "HIV Reception", "HIV Staging", "Height/Weight", "Update outcome", "View reports"]

    User.find_all.each{|user|
      roles = user.roles.collect{|r|r.role}.uniq
      if user.activities.length > 0
        puts "#{user.username}: already has activities"
        next
      end
      puts "#{user.username} #{roles.join(',')}"
      if roles.include?("Registration Clerk")
        user.activities = ["HIV First visit", "HIV Reception", "Update outcome", "View reports"]
      elsif roles.include?("Vitals Clerk")
        user.activities = ["Height/Weight"]
      elsif roles.include?("Nurse")
        user.activities = ["ART Visit", "Give drugs"]
      elsif roles.include?("Clinician")
        user.activities = ["ART Visit", "HIV Staging"]
      elsif roles.include?("Pharmacist")
        user.activities = ["Give drugs"]
      end
    }
    nil
  end

end
