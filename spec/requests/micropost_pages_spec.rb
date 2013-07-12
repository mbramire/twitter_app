require 'spec_helper'

describe "Micropost pages" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	let(:followed_user) { FactoryGirl.create(:user) }
	before { valid_signin user }

	describe "micropost creation" do
		before { visit root_path }

		describe "with invalid information" do

			it "should not create a micropost" do
				expect { click_button "Post" }.not_to change(Micropost, :count)
			end

			describe "error messages" do
				before { click_button "Post" }
				it { should have_content('error') }
			end
		end

		describe "with valid information" do

			before { fill_in 'micropost_content', with: "Lorem ipsum" }
			it "should create a micropst" do
				expect { click_button "Post" }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe "micropost destruction" do
		
		describe "as correct user" do
		  before do  
		  	FactoryGirl.create(:micropost, user: user)
		  	visit root_path
		  end

		  it "should delete a micropost" do
		    expect { click_link "delete" }.to change(Micropost, :count).by(-1)
		  end
		end

		describe "for a followed user" do
			before do 
				FactoryGirl.create(:micropost, user: followed_user) 
				visit root_path
			end

			it { should_not have_link('delete') } 
		end
	end

	describe "micoropost aside" do
		before do 
			FactoryGirl.create(:micropost, user: user)
			FactoryGirl.create(:micropost, user: user)
			visit root_path
		end
		
		it { should have_content('2 microposts') }
	end
end