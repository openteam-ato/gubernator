@init_galleria = ->
  $('.js-galleria-item').each (index, item) ->
    title = $(item).find('.js-title')
    item_height = $(title).height()

    $(title).attr('data-height', item_height)

    $(title).innerHeight('27px')

    $('.js-galleria-link', item)
      .mouseover ->
        return if $(title).height() > $(title).data('height')

        $(title).stop(true, true).animate
          height: item_height + 10
        , 300
        return
      .mouseout ->
        $(title).stop(true, true).animate
          height: 27
        , 300
        return
