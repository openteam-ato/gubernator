$ ->
  init_main_page_gallery() if $('.js-main_page-galleria').length
  init_colorbox() if $('.js-colorbox').length
  init_slogan() if $('.js-quotes-list').length

  init_fixed_menu()
