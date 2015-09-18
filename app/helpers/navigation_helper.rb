module NavigationHelper

  def render_navigation_with_separator(hash, klass = nil)
    return '' if hash.nil? || hash.empty?

    content_tag :ul, :class => [klass, 'nav', 'navbar-nav'] do
      index = 0

      hash.map do |key, value|
        index += 1

        content_tag :li, :class => value['selected'] ? :active : nil do
          link_to(value['title'], value['path'], :class => key) +
            render_navigation(value['children'] || {})
        end
      end.join(' ').html_safe
    end
  end

  def render_navigation(hash)
    return '' if hash.nil? || hash.empty?

    content_tag :ul do
      index = 0
      hash.map do |key, value|
        index += 1
        content_tag :li, :class => [value['selected'] ? :selected : nil, key].compact.join(' ') do
          content_tag(:p, link_to(value['title'].html_safe, value['path'], :class => key)) + render_navigation(value['children'] || {})
        end
      end.join(' ').html_safe
    end
  end

  private
    def separator(size, index)
      (' ' + content_tag(:li, '&nbsp;'.html_safe, :class => css_class(size, index))).html_safe
    end

    def css_class(size, index)
      index < size ? 'separator' : 'break'
    end
end
