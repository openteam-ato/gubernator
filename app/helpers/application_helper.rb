module ApplicationHelper
  def page_title(title = nil)
    @page_title ||= I18n.t("page_title.#{controller_name}.#{action_name}", :title => title).html_safe
  end

  def render_partial_for_region(region, prefix = nil)
    prefix = "#{prefix}_" if prefix.present?
    if region && (region.response_status == 200 || !region.response_status?)
      partial = "regions/#{prefix}#{region.template}"
      render :partial => partial,
      :locals => { :object => region.content, :response_status => region.response_status }
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
        klass << 'has_children' if value['children'] && value['title'] != 'Почему ТУСУР?'
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

  def humanize_passing_score(passing_score_budget, passing_score_payment, budget_places)
    if passing_score_budget == passing_score_payment
      content_tag(:abbr, passing_score_budget, :title => 'Минимальный пороговый балл', :class => 'js-tooltip')
    else
      if budget_places > 0
        content_tag(:abbr, passing_score_budget, :title => 'Минимальный пороговый балл на бюджетное место', :class => 'js-tooltip') + ', ' +
        content_tag(:abbr, passing_score_payment, :title => 'Минимальный пороговый балл на платное место', :class => 'js-tooltip')
      else
        content_tag(:abbr, passing_score_payment, :title => 'Минимальный пороговый балл', :class => 'js-tooltip')
      end
    end
  end

  def empty_message
    arr = []
    message = ''
    return message if params['subjects'].blank?
    params['subjects'].each do |subject|
      if subject.second['is_selected'] == 'true'
        subj = @subjects.subjects.select {|s| s['slug'] == subject.first}.first
        arr << subj if subj['passing_score_payment'].to_i > subject.second['passing_score'].to_i && subject.second['passing_score'].to_i > 0
      end
    end
    content_tag :p, "Количество баллов, которое вы указали, ниже минимального порогового балла: #{arr.map{|s| s['kind']}.join(', ')}", :class => :warning unless arr.empty?
  end

  def warning_message
    arr = params['subjects']

    message = ''
    return message if arr.try(&:values).blank?

    #if arr['matematika'] && arr['matematika']['is_selected'] == 'true'
      #matematika_passing_score = arr['matematika']['passing_score'].to_i
      #matematika = Subject.find_by_slug('matematika')
      #if matematika_passing_score >= matematika.passing_score_payment && matematika_passing_score < matematika.passing_score_budget
        #message += content_tag :p, "С указанным количеством баллов по математике (#{matematika_passing_score}) вы можете претендовать только на платное место", :class => :warning
      #end
    #end

    if arr.values.select{ |hash| hash['is_selected'] == 'true' }.size < 3
      message += content_tag :p, 'Необходимо выбрать минимум 3 вступительных испытания!', :class => :warning
    end

    arr = arr.values.uniq.select{ |hash| hash['is_selected'] == 'true' }
    if arr.select{ |hash| hash['passing_score'] != '0' }.count > 0 && arr.select{ |hash| hash['passing_score'] == '0' }.count > 0
      message += content_tag :p, 'Результаты фильтрации могут не соответствовать действительности. Укажите баллы для всех вступительных испытаний!', :class => :warning
    end

    message.html_safe
  end

  def online_help_operation_time
    ( !Time.zone.now.sunday? && Time.zone.now > Time.zone.parse('9:00:00') && Time.zone.now < Time.zone.parse('18:00:00') ) ||
    ( Time.zone.now.saturday? && Time.zone.now > Time.zone.parse('10:00:00') && Time.zone.now < Time.zone.parse('15:00:00') )
  end

  def current_namespace
    controller_path.split('/')[-2].try(:to_sym)
  end

end
