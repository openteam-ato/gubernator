@init_slogan = ->

  $('.js-quotes-list ul').shuffle()

  $('.js-quote').text(
    $('.js-quotes-list ul li:eq(0)').addClass('visible').text()
  ).append('<span class="quote_r">"</span>')

  return if $('.js-quotes-list ul li').length < 2

  setInterval ->
    $('.js-quote').fadeOut 'fast', ->

      visible = $('.js-quotes-list ul li.visible')

      $('.js-quote').text(
        visible.next().text()
      ).append('<span class="quote_r">"</span>')

      visible.next().addClass('visible')
      $('.js-quotes-list ul').append(visible.removeClass('visible'))
      $('.js-quote').fadeIn('fast')

      return

    return
  , 20000

  return
