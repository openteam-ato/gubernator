@init_fixed_menu = () ->
  sidebar = $('.js-menu-sidebar')

  $('.js-fixed-menu').stick_in_parent(
    offset_top: 10
  ).on("sticky_kit:stick", ->
    $('.mainblock').removeClass('col-xs-offset-2')
    $('.mainblock').css(
      {
        'float': 'left',
        'padding-left': '35px'
      }
    )
  ).on("sticky_kit:unstick", ->
    $('.mainblock').addClass('col-xs-offset-2')
    $('.mainblock').css(
      {
        'float': 'none',
        'padding-left': '15px'
      }
    )
  )

  navs = $('a', sidebar)

  sections = $('.js-scrolltrack')

  busy = false

  sections_positions = []
  sections.each (index, item) ->
    sections_positions.push($(this).offset().top - 10)

    return

  current_index = 0
  len = sections_positions.length

  getCurrent = (top) ->
    i = 0
    while i <= len
      if top > sections_positions[i] && top < sections_positions[i+1]
        return i
      i++

    return

  $(window).scroll ->
    scrollTop = $(this).scrollTop()

    return if busy

    checkIndex = getCurrent(scrollTop)
    if checkIndex != currentIndex
      currentIndex = checkIndex
      navs.removeClass('active')
      current =  navs.eq(currentIndex)

      $('> a', current.parent()).addClass('active')

    return

  $('a', sidebar).click (e) ->
    href = $(this).attr('href')
    busy = true
    $.scrollTo href, 500,
      onAfter: ->
        window.location.replace href
        busy = false
        return
    $('.active', sidebar).removeClass('active')
    $('> a', $(this).parent()).addClass('active')

    return false

  if window.location.hash.length
    $('> a', $("a[href=#{window.location.hash}]").parent()).addClass('active')

  return
