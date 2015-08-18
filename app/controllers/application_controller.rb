class ApplicationController < CommonController
  include Cmsable

  private

  def remote_url
    origin_request_path, parts_params = request.fullpath.split('?')

    request_path = origin_request_path

    ["#{cms_address}#{request_path.gsub('//', '/').split('/').compact.join('/')}.json", parts_params].compact.join('?')
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
