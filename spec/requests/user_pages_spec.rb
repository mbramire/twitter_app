require 'spec_helper'

describe "User pages" do

  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  describe "index page" do

    before(:each) do
      valid_signin user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          valid_signin admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

  describe "profile page" do
	  before { visit user_path(user) }

	  it { should have_selector('h1',    text: user.name) }
	  it { should have_selector('title', text: user.name) }
	end

  describe "user sign up" do
    before { visit signup_path }
    let(:submit) { "Create my account" } 

    describe "with invalid data" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count) 
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_content('error') }
        it { should have_selector('title', text: 'Sign up') }
      end
    end

    describe "with valid data" do
      before do
        fill_in "Name", with: "First Last"
        fill_in "Email", with: "email@email.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('email@email.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "followed by sign out" do
        it { should have_link('Sign in') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do 
      valid_signin user
      visit edit_user_path(user)
    end
    
    describe "page" do 
      it { should have_selector('h1', text: "Edit your profile") }
      it { should have_selector('title', text: 'Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:newname) { "New Name" }
      let(:newemail) { "new@email.com" }
      before do
        fill_in "Name", with: newname
        fill_in "Email", with: newemail
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: newname) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == newname }
      specify { user.reload.email.should == newemail }
    end
  end
end