$ ->
  $('body').on 'click', '.js-slide-up', ->
    $('html, body').animate({ scrollTop: 0 }, "slow")

    false

  $(window).scroll ->
    if $(this).scrollTop() > 1500
      $('.js-slide-up').show()

    else
      $('.js-slide-up').hide()

    return

