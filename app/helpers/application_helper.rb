module ApplicationHelper

  def canonical_url
    return "<link rel='canonical' href='/' />" if request.path == '/ru'

    ''
  end

  def page_title(title = nil)
    @page_title ||= I18n.t("page_title.#{controller_name}.#{action_name}", :title => title).html_safe
  end

  def render_partial_for_region(region, prefix = nil)
    prefix = "#{prefix.to_s.parameterize('_').underscore}_" if prefix.present?
    if region && (region.response_status == 200 || !region.response_status?)
      partial = "regions/#{prefix}#{region.template}"
      render :partial => partial,
      :locals => { :part_title => region.part_title, :object => region.content, :response_status => region.response_status }
    else
      render :partial => 'regions/error', :locals => { :region => region }
    end
  end

  def render_cms_navigation(hash, list_class = nil, item_class = nil)
    return '' if hash.nil? || hash.empty?
    content_tag :ul, :class => list_class do
      hash.map do |key, value|
        klass = []
        klass << item_class
        klass << 'active' if value['selected']
        klass << 'has_children' if value['children']
        klass = klass.delete_if(&:blank?).join(' ').squish
        klass = nil if klass.empty?
        content_tag :li, :class => klass do
          render_link_for_navigation(value)
        end
      end.join.html_safe
    end
  end

  def render_link_for_navigation(item)
    if item['external_link'].present?
      if item['external_link'].match(/\Ahttps?/)
        link_to item['title'], item['external_link'], :target => :_blank
      else
        link_to item['title'], item['external_link']
      end
    else
      link_to item['title'], item['path']
    end
  end

  def render_client_navigation(hash)
    return '' if hash.nil? || hash.empty?
    content_tag :ul do
      hash.map do |key, value|
        content_tag :li, :class => value['selected'] ? 'selected' : nil do
          link_to(value['title'], value['external_link'].present? ? value['external_link'] : value['path']) + render_client_navigation(value['children'])
        end
      end.join.html_safe
    end
  end

  def current_namespace
    controller_path.split('/')[-2].try(:to_sym)
  end

  def from_russian_to_param(title)
    Russian.translit(title.sub(' ', '-')).downcase!.underscore.dasherize
  end

  def entry_date
    @entry_date ||= begin
                      @page.regions.to_hash.each do |region_name, region|
                        if (since = region.try(:[], 'content').try(:[], 'since'))
                          return since
                        end
                      end
                      nil
                    end
  end

  def entries_rss_link(parts_array)
    part = parts_array.compact.select { |part| part.content.rss_link }.first
    part.content.rss_link if part
  end

  def archive_links(parts_array)
    return [] unless parts_array.present?

    base_path = parts_array.content.collection_link || request.path.split("-").first.gsub(/\/prosmotr\//,"")

    list_type = "news_list"

    current_year = params[:parts_params].try(:[], list_type).try(:[], "interval_year") || DateTime.parse(parts_array.content.try(:since)).year rescue ''

    result = gallery_years.map do |year|
      content_tag :li, link_to(year, "#{base_path}?"+url_encode("parts_params[#{list_type}][interval_year]")+"="+year.to_s), :class => current_year.to_s == year.to_s ? 'active' : nil
    end

    result
  end

  def gallery_years
    (2012..Time.zone.now.year.to_i).map { |year| year }.reverse
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
end
