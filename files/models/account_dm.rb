class Account
  include DataMapper::Resource
  include DataMapper::Validate
  attr_accessor :password, :password_confirmation

  # Properties
  property :id, Serial
  property :name, String
  property :surname, String
  property :email, String
  property :crypted_password, String
  property :salt, String
  property :role, String

  # Validations
  validates_presence_of :email, :role
  validates_presence_of :password, :if => :password_required
  validates_presence_of :password_confirmation, :if => :password_required
  validates_confirmation_of :password, :if => :password_required
  validates_length_of :email, :min => 3, :max => 100
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :with => :email_address
  validates_format_of :role, :with => /[A-Za-z]/

  before :save, :encrypt_password

  ##
  # This method is for authentication purpose
  #
  def self.authenticate(email, password)
    a = self.first(:conditions => { :email => email }) if email.present?
    a && a.crypted_password == encrypt(a.salt, password) ? a : nil
  end

  ##
  # This method is used by AuthenticationHelper
  #
  def self.find_by_id(id)
    get(id) rescue nil
  end

  def self.encrypt(salt, password)
    Digest::SHA1.hexdigest("#{salt}--#{password}")
  end

  def encrypt_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}") if new?
    unless password.blank?
      self.crypted_password = self.class.encrypt(self.salt, self.password)
    end
  end

  private
  def password_required
    crypted_password.blank? || !password.blank?
  end
end