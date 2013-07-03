require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid info" do
    	before { click_button "Sign in"}

	    it { should have_selector('title', text: 'Sign in') }
	    it { should have_error_message('Invalid') }

	    describe "and visit another page" do
	    	before { click_link "Home" }
	    	it { should_not have_selector('div.alert.alert-error') }
	    end
	  end

	  describe "with valid info" do
	  	let(:user) { FactoryGirl.create(:user) }
	  	before { valid_signin(user) }

	  	it { should have_selector('title', text: user.name) }
			it { should have_link('Sign out', href: signout_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user)) }
			it { should_not have_link('Sign in', href: signin_path) }	  	
	  end
  end
end