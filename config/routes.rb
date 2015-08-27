Gubernator::Application.routes.draw do
  root :to => 'application#index'

  # legacy routes
  get '/biografiya'           => redirect('/ru/biografiya')
  get '/news'                 => redirect('/ru/novosti')
  get '/words'                => redirect('/ru/pozitsiya/pozitsiya')
  get '/interview'            => redirect('/ru/pozitsiya/intervyu')
  get '/photo'                => redirect('/ru/galereya/galereya')
  get '/photo-krupnyimplanom' => redirect('/ru/galereya/krupnym-planom')
  get '/photo-archive'        => redirect('/ru/galereya/arhiv')
  get '/video'                => redirect('/ru/video')
  get '/personal'             => redirect('/ru/uvlecheniya')

  get '/(*path)', :to => 'application#index'

end
