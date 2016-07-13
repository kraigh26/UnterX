class SitemapController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::MimeResponds
  include ActionController::DataStreaming
  include ActionController::RackDelegation
  include ActionController::Rescue
  include ActionController::Head

  def sitemap
    if false
      redirect_to "/" # The CDN then fetches the sitemap.xml from the sitemap/generate URL which points to the `generate` action
    else
      render_site_map
    end
  end

  def generate
    render_site_map
  end

  private

    def render_site_map
      respond_to do |format|

          adapter = SitemapGenerator::NeverWriteAdapter.new

          SitemapGenerator::Sitemap.create(
                :default_host => 'http://example2.com',
                :adapter => adapter) do
            Listing.where(deleted: false, open: true, community_id: 1).find_each do |listing|
              add listing_path(listing), :lastmod => listing.updated_at
            end
          end

          #SitemapGenerator::Interpreter.run(:default_host => "http://www.bar.com", :adapter => adapter)
          data = adapter.get_data
          format.xml_gz { send_data  ActiveSupport::Gzip.compress(data) }
          format.html { send_data  ActiveSupport::Gzip.compress(data) }
      end
    end
end
