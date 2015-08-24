@init_slogan = ->
  $('.js-quotes-list ul').shuffle()

  $('.js-quote').text(
    $('.js-quotes-list ul li:eq(0)').text()
  ).append('<span class="quote_r">"</span>')

  return if $('.js-quotes-list ul li').length < 2

  $('.js-quotes-list ul').shuffle()

  setInterval ->
    $('.js-quote').fadeOut 'fast'

    $('.js-quote').text(
      $('.js-quotes-list ul li:nth-child(1)').text()
    ).append('<span class="quote_r">"</span>')

    $('.js-quotes-list ul').append($('.js-quotes-list ul li:nth-child(1)'))

    $('.js-quote').fadeIn('fast')

    return
  , 10000

  return
