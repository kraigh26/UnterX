require 'spec_helper'

RSpec.describe SitemapController, type: :controller do

  let(:valid_session) { {} }

  before(:each) do
    @community = FactoryGirl.create(:community)
    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community
    @person = FactoryGirl.create(:person)

    FactoryGirl.create(:community_membership, :person => @person, :community => @community)
    @listing = FactoryGirl.create(:listing, community_id: @community.id)
  end

  describe "GET #sitemap" do
    it "creates sitemap" do
      get :sitemap, {}, valid_session
      expect(response.status).to eq(200) 
    end
  end

  describe "GET #sitemap_generate" do
    it "creates sitemap" do
      get :generate, {}, valid_session
      expect(response.status).to eq(200) 
    end
  end

end
