require 'active_support/concern'

module Cmsable
  extend ActiveSupport::Concern

  included do
    before_action :load_cms_data
  end

  private

  def load_cms_data
    render :file => "#{Rails.root}/public/404", :formats => [:html], :layout => false, :status => 404 and return if request_status == 404

    page_regions.each do |region|
      eval "@#{region} = page.regions.#{region}"
    end

    @site_title = @site_name.try(:content).try(:body) || 'Абитуриент ТУСУР'
    @page_title = page.title
    @navigation_title = page.navigation_title
    @page_meta = page.meta
    @link_to_json = remote_url

    render "templates/#{page.template}" unless page.template == 'educations'
  end

  def remote_url
    raise 'Override me'
  end

  def cms_address
    @cms_address ||= "#{Settings['cms.url']}/nodes/#{Settings['cms.site_slug']}"
  end

  def curl_request
    @curl_request ||= Curl::Easy.perform(remote_url) do |curl|
      curl.headers['Accept'] = 'application/json'
    end
  end

  def request_status
    @request_status ||= curl_request.response_code
  end

  def request_body
    @request_body ||= curl_request.body_str
  end

  def page_regions
    @page_regions ||= page.regions.keys
  end

  def page
    @page ||= Hashie::Mash.new(request_json).page
  end

  def is_json?(str)
    begin
      !!JSON.parse(str)
    rescue
      false
    end
  end

  def request_json
    @request_json ||= begin
                        raise ActionController::RoutingError.new('Not Found') unless is_json?(request_body)
                        ActiveSupport::JSON.decode(request_body)
                      end
  end
end
