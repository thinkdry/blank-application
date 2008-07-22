require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  
  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'monkey')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
  
  # our tests
  
  def test_firstname_should_be_valid
    # require, [a-z], [A-Z], '-', accentued chars
    ["", "jdk@k", "1234"].each do |f|
      assert_no_difference 'User.count' do
        u = create_user(:firstname => f)
	assert u.errors.on(:firstname), "Column firstname should return an error with value \"#{f}\"."
      end
    end
  end
  
  def test_lastname_should_be_valid
    # require, [a-z], [A-Z], '-', accentued chars
    ["", "jdk@k", "1234"].each do |l|
      assert_no_difference 'User.count' do
        u = create_user(:lastname => l)
	assert u.errors.on(:lastname), "Column lastname should return an error with value \"#{l}\"."
      end
    end
  end
  
  def test_email_should_be_valid
    # require, mail format
    ["", "jdk@k", "jdk@ffff.f"].each do |e|
      assert_no_difference 'User.count' do
        u = create_user(:email => e)
	assert u.errors.on(:email), "Column email should return an error with value \"#{l}\"."
      end
    end
  end
  
  def test_address_should_be_valid
    # require
    [""].each do |a|
      assert_no_difference 'User.count' do
        u = create_user(:addr => a)
	assert u.errors.on(:addr), "Column address should return an error with value \"#{a}\"."
      end
    end
  end
  
  def test_laboratory_should_be_valid
    # require, [a-z], [A-Z], '-', accentued chars
    ["", "jdk@k", "1234"].each do |l|
      assert_no_difference 'User.count' do
        u = create_user(:laboratory => l)
	assert u.errors.on(:lalaboratory), "Column laboratory should return an error with value \"#{l}\"."
      end
    end
  end
  
  def test_phone_should_be_valid
    # require, 10 numbers expected
    ["", "jdk@k", "1234", "11 11 11 1"].each do |p|
      assert_no_difference 'User.count' do
        u = create_user(:phone => p)
	assert u.errors.on(:phone), "Column phone should return an error with value \"#{p}\"."
      end
    end
  end
  
  def test_mobile_should_be_valid
    # require, 10 numbers expected
    ["", "jdk@k", "1234", "11 11 11 1"].each do |m|
      assert_no_difference 'User.count' do
        u = create_user(:mobile => m)
	assert u.errors.on(:mobile), "Column mobile should return an error with value \"#{m}\"."
      end
    end
  end
  
  def test_activity_should_be_valid
    # [a-z], [A-Z], '-', accentued chars
    ["jdk@k", "1234"].each do |a|
      assert_no_difference 'User.count' do
        u = create_user(:activity => a)
	assert u.errors.on(:activity), "Column activity should return an error with value \"#{a}\"."
      end
    end
  end
  
  
  
  
protected
  def create_user(options = {})
    record = User.new({
      :login => 'quire',
      :email => 'quire@example.com',
      :password => 'quire69',
      :password_confirmation => 'quire69',
      :firstname => 'quire',
      :lastname => 'dupond',
      :addr => '42 rue du paradis',
      :laboratory => 'myLab',
      :phone => '0112345678',
      :mobile => '0612345678',
      :activity => 'nothingAtAll',
      :edito => 'Ici mon edito' }.merge(options))
    record.save
    record
  end
end
