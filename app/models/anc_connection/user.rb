require 'digest/sha1'
require 'digest/sha2'

class AncConnection::User < ActiveRecord::Base
  self.establish_connection :anc
	# devise :database_authenticatable, :token_authenticatable,
	#	:authentication_keys => [:login]

	set_table_name :users
	set_primary_key :user_id
	include AncConnection::Openmrs

	before_save :set_password, :before_create
	
	attr :plain_password
	#cattr_accessor :current_user
	attr_accessor :plain_password
	attr_accessor :password_salt
	attr_accessor :encrypted_password
	#attr_accessor :secret_question
	#attr_accessible :encrypted_password
	# User name attribute for Devise

	# Virtual attribute for authenticating by either username or email
	# This is in addition to a real persisted field like 'username'
	attr_accessor :login
	attr_accessible :login, :username, :password, :secret_question

	belongs_to :person, :foreign_key => :person_id, :conditions => {:voided => 0}
	has_many :user_properties, :foreign_key => :user_id # no default scope
	has_many :user_roles, :foreign_key => :user_id, :dependent => :delete_all # no default scope
	#has_many :names, :class_name => 'PersonName', :foreign_key => :person_id, :dependent => :destroy, :order => 'person_name.preferred DESC', :conditions => {:voided =>  0}

	def set_password
		# We expect that the default OpenMRS interface is used to create users
		#self.password = self.encrypted_password
		self.password = encrypt(self.plain_password, self.salt) if self.plain_password
	end
  
	has_one :activities_property,
		  :class_name => 'UserProperty',
		  :foreign_key => :user_id,
		  :conditions => ['property = ?', 'Activities'] 

	# Custom search method for our custom login attribute
	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		login = conditions.delete(:login)
		where(conditions).where(["lower(username) = :value", { :value => login.strip.downcase }]).first
	end

	def self.authenticate(username, password)
		user = User.find_for_authentication(:username => username)
		user.valid_password?(password) ? user : nil if !user.nil?
	end

	def valid_password?(password)
		return false if encrypted_password.blank?
	  	is_valid = Digest::SHA1.hexdigest("#{password}#{salt}") == encrypted_password	|| encrypt(password, salt) == encrypted_password || Digest::SHA512.hexdigest("#{password}#{salt}") == encrypted_password
	end

	def first_name
		self.person.names.first.given_name rescue ''
	end

	def last_name
		self.person.names.first.family_name rescue ''
	end

	def name
		name = self.person.names.first
		"#{name.given_name} #{name.family_name}"
	end

	def try_to_login
		User.authenticate(self.username, self.password)
	end

	def password_salt
		salt
	end
  
	# overwrite this method so that we call the encryptor class properly
	def encrypt_password
	  unless @password.blank?
		self.password_salt = salt
		self.encrypted_password = encrypt(@password, salt)
	  end
	end

	# Because when the database_authenticatable wrote the following method to regenerate the password, which in turn passed incorrect params to the encrypt_password, these overwrite is needed!
	def password
		# We expect that the default OpenMRS interface is used to create users
		#self.password = encrypt(self.plain_password, self.salt) if self.plain_password
		#raise @password.to_yaml
		self[:password]
	end

	def password_digest(pwd)
		encrypt(pwd, salt)
	end

	def encrypted_password
		self.password
	end
   
=begin
	def authenticated?(plain)
		encrypt(plain, salt) == password || Digest::SHA1.hexdigest("#{plain}#{salt}") == password || Digest::SHA512.hexdigest("#{plain}#{salt}") == password
	end
=end
	def admin?
		admin = user_roles.map{|user_role| user_role.role }.include? 'Informatics Manager'
		admin = user_roles.map{|user_role| user_role.role }.include? 'System Developer' unless admin
		admin = user_roles.map{|user_role| user_role.role }.include? 'Superuser' unless admin
		admin
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

	def before_create
		super
		self.salt = User.random_string(10) if !self.salt?
		self.password = User.encrypt(plain_password, salt) if plain_password
	end
 
	def self.random_string(len)
		#generat a random password consisting of strings and digits
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpass = ""
		1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
		return newpass
	end

	def self.encrypt(password,salt)
		Digest::SHA1.hexdigest(password+salt)
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

	def self.current
		Thread.current[:user]
	end

	def self.current=(user)
		Thread.current[:user] = user
	end
end
