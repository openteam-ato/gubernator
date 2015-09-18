class CmsData

  def remote_url
    "#{cms_address}"
  end

  def response_hash(locale)
    cms_address = "#{Settings['cms.url']}/nodes/#{Settings['cms.site_slug']}"
    remote_url = "#{cms_address}/#{locale}/sitemap.json"
    curl_request = Curl::Easy.perform(remote_url) do |curl|
      curl.headers['Accept'] = 'application/json'
    end
    request_body = curl_request.body_str
    request_json = ActiveSupport::JSON.decode(request_body)

    request_json['page'].try(:[], 'regions').try(:[], 'content').try(:[], 'content')
  end

  def find_all_values_for(hash)
    return [] if hash.nil? || hash.empty?
    result = []
    hash.map do |key, value|
      path = value['external_link'].presence || value['path']
      result << { :path => path, :lastmod => value['lastmod'] }
      result << find_all_values_for(value['children'])
    end
    result.delete_if(&:blank?).flatten
  end

  def find_all_paths
    paths = []
    I18n.available_locales.each do |locale|
      paths += find_all_values_for(response_hash(locale))
    end
    paths = paths.reverse.uniq{ |hash| hash[:path] }.reverse

    paths
  end
end

SitemapGenerator::Sitemap.default_host = Settings['app.url']
SitemapGenerator::Sitemap.sitemaps_path = File.expand_path('../../../../shared/sitemaps/', __FILE__) if Rails.env.production?
SitemapGenerator::Sitemap.create_index = false
SitemapGenerator::Sitemap.include_root = true

SitemapGenerator::Sitemap.create do

  paths = CmsData.new.find_all_paths

  paths.each do |hash|
    add hash[:path], :lastmod => hash[:lastmod]
  end

  paths = []

  paths.uniq{ |hash| hash[:path] }.each do |hash|
    add hash[:path], :lastmod => hash[:lastmod]
  end

end

Kernel.system "gunzip -c #{Rails.root.join('public')}/sitemap.xml.gz > #{Rails.root.join('public')}/sitemap.xml" if Rails.env.development?

SitemapGenerator::Sitemap.ping_search_engines(
  "#{Settings['app.url']}/sitemap.xml.gz",
  :yandex => 'https://blogs.yandex.ru/pings/?status&url=%s'
)
