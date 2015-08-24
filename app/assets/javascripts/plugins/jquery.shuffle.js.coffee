(($) ->
  $.fn.shuffle = ->
    @each ->
      items = $(this).children().clone(true)
      if items.length
        $(this).html($.shuffle(items))
      else
        this

  $.shuffle = (arr) ->
    j = undefined
    x = undefined
    i = arr.length

    while i
      j = parseInt(Math.random() * i)
      x = arr[--i]
      arr[i] = arr[j]
      arr[j] = x
    arr
) jQuery
