@init_main_page_gallery = ->
  $('.js-main_page-galleria').isotope
    itemSelector: '.js-main_page-galleria-item'
    layoutMode: 'packery'

    true

  zoom = 1.2 # коэффициент для ширины и высоты

  $('.js-main_page-galleria-item img').each (index, item) ->
    element = $(this)
    original_width = element.width()
    target_width = Math.round(element.width() * zoom)
    original_height = element.height()
    target_height = Math.round(element.height() * zoom)
    element
    .mouseover ->
      $(element).closest('li').addClass('hover').siblings().addClass('grayscale')
      $(element).css('z-index', '1').stop(true, true).animate
        left: "-=#{(target_width - original_width) / 2}"
        top: "-=#{(target_height - original_height) / 2}"
        width: target_width
        height: target_height
      , 300
      return
    .mouseout ->
      $(element).closest('li').removeClass('hover').siblings().removeClass('grayscale')
      $(element).css('z-index', '0').stop(true, true).animate
        left: "+=#{(target_width - original_width) / 2}"
        top: "+=#{(target_height - original_height) / 2}"
        width: original_width
        height: original_height
      , 300
      return

    return
