class User < ActiveRecord::Base

# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # Bitwise comparison e.g.:
  # NOTE: "**" = exponent syntax (^) in Ruby
  #
  # Say a user has a moderator and author role (2**1 + 2**2 = 5) which is
  # then stored as user.roles_mask. To see if the user has any combination of
  # roles, we can check with "with_role." For example, to see if tha user has
  # the author role, run: with_role(author). This triggers a bitwise comparison
  # between the stored roles: "roles_mask & 4 > 0" ("6 & 4 > 0"). This
  # translates to "6 & 4 > 0" which is a bitwise operation that evaluates to
  # "true" (6 & 4 = 4). See more at:
  # http://asilia.herokuapp.com/2011/04/06/bitmask-attributes-on-a-rails-application
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }

  ROLES = %w[admin librarian moderator]

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def has_role?(role)
    roles.include? role.to_s
  end

  def has_one_of_these_roles?(check_roles)
    check_roles.map {|role| roles.include? role.to_s }.include?(true)
  end
end
