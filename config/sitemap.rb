require 'progress_bar'
require 'time_diff'

class CmsData

  def cms_address
    "#{Settings['cms.url']}/nodes/#{Settings['cms.site_slug']}"
  end

  def response(url)
    response_json = {}
    RestClient::Request.execute(
      method: :get,
      url: url,
      timeout: 600,
      headers: { :Accept => 'application/json', :timeout => 600 }
    ) do |response, request, result, &block|
      response_json = (ActiveSupport::JSON.decode(response.body) rescue {})
    end

    print '#'

    response_json
  end

  def response_locale(locale)
    url = "#{cms_address}/#{locale}/sitemap.json"
    response(url)['page'].try(:[], 'regions').try(:[], 'content').try(:[], 'content')
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

  def allow_part_types
    ['NewsListPart', 'EventsListPart']
  end

  def news_urls_for(paths)
    news_paths = []
    paths.each do |path|
      url = "#{cms_address}#{path[:path]}.json"
      response_json = response(url)

      puts "\nregions is nil for: #{url}" if response_json.try(:[], 'page').try(:[], 'regions').blank?
      response_json.try(:[], 'page').try(:[], 'regions').each do |region_name, region_content|
        next if region_content.blank? || allow_part_types.exclude?(region_content.try(:[], 'type'))
        news_list_part = region_content.try(:[], 'content')
        news_paths += news_list_part.try(:[], 'items').map{ |item| { :path => item['link'], :lastmod => item['updated_at'] } }
        if news_list_part.try(:[], 'pagination').present?
          total_count = news_list_part.try(:[], 'pagination').try(:[], 'total_count').to_f
          per_page = news_list_part.try(:[], 'pagination').try(:[], 'per_page').to_f
          pages = (total_count / per_page).ceil if per_page != 0
          (2..pages.to_i).each do |page|
            response_json = response("#{url}?page=#{page}")
            puts "\nregions is nil for: #{url}" if response_json.try(:[], 'page').try(:[], 'regions').blank?
            response_json.try(:[], 'page').try(:[], 'regions').each do |region_name, region_content|
              next if region_content.blank? || allow_part_types.exclude?(region_content.try(:[], 'type'))
              news_list_part = region_content.try(:[], 'content')
              news_paths += news_list_part.try(:[], 'items').map{ |item| { :path => item['link'], :lastmod => item['updated_at'] } }
            end
          end
        end
      end
    end

    news_paths
  end

  def find_all_paths
    start_time = Time.zone.now
    puts "Start: #{I18n.l(start_time)}"
    paths = []
    I18n.available_locales.each do |locale|
      paths += find_all_values_for(response_locale(locale))
    end
    paths = paths.delete_if{ |hash| hash[:path].scan(/\Ahttps?/).any? }
    paths = paths.reverse.uniq{ |hash| hash[:path] }.reverse
    paths += news_urls_for(paths)
    paths = paths.uniq{ |hash| hash[:path] }.sort{ |a, b| a[:path] <=> b[:path] }
    end_time = Time.zone.now
    puts "\nFinish: #{I18n.l(end_time)}"
    puts "Diff: #{Time.diff(start_time, end_time)[:diff]}"
    puts "Count of links: #{paths.count}"

    paths
  end
end

SitemapGenerator::Sitemap.default_host = Settings['app.url']
SitemapGenerator::Sitemap.sitemaps_path = Rails.root.join('public') if Rails.env.development?
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
Kernel.system "gunzip -c #{SitemapGenerator::Sitemap.sitemaps_path}/sitemap.xml.gz > #{SitemapGenerator::Sitemap.sitemaps_path}/sitemap.xml" if Rails.env.production?

SitemapGenerator::Sitemap.ping_search_engines(
  "#{Settings['app.url']}/sitemap.xml.gz",
  :google => 'https://google.com/ping?sitemap=%s',
  :yandex => 'https://blogs.yandex.ru/pings/?status&url=%s'
) if Rails.env.production?
