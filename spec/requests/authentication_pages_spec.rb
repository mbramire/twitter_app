require 'spec_helper'

describe "Authentication" do

  subject { page }
  let(:user) { FactoryGirl.create(:user) }

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
	  	before { valid_signin(user) }

	  	it { should have_selector('title', text: user.name) }
			it { should have_link('Sign out', href: signout_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Users', href: users_path) }
			it { should_not have_link('Sign in', href: signin_path) }	  	
	  end
  end

  describe "Authorization" do
  	describe "for non-signed in users" do

  		describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
        end
      end

      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end
      end

  		describe "in the users controler" do

  			describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "trying to access the users index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end
  		end
  	end

  	describe "as the wrong user" do
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { valid_signin user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
  	end

    describe "as a non-admin user" do
      let(:non_admin) { FactoryGirl.create(:user) }

      before { valid_signin non_admin }

      describe "submitting a delete request to the User#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end
  end
end