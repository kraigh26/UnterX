class SitemapController < ApplicationController

  def sitemap
    #if false
      #redirect_to "/" # The CDN then fetches the sitemap.xml from the sitemap/generate URL which points to the `generate` action
    #else
    render_site_map
    #end
  end

  def generate
    render_site_map
  end

  private

    def render_site_map
      respond_to do |format|

        data = Rails.cache.fetch(@current_community, expires_in: 24.hours) do
          adapter = SitemapGenerator::NeverWriteAdapter.new

          if @current_community.use_domain 
            default_host = "https://"+@current_community.domain
          else 
            default_host = "https://"+APP_CONFIG.domain
          end

          SitemapGenerator::Sitemap.create(
                :default_host => default_host,
                :adapter => adapter) do
            Listing.where(deleted: false, open: true, community_id: 1).find_each do |listing|
              add listing_path(listing), :lastmod => listing.updated_at
            end
          end

          #SitemapGenerator::Interpreter.run(:default_host => "http://www.bar.com", :adapter => adapter)
          data = adapter.get_data
        end
        format.xml_gz { send_data  ActiveSupport::Gzip.compress(data) }
        format.html { send_data  ActiveSupport::Gzip.compress(data) }
      end
    end
end
