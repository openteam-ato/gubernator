Gubernator::Application.routes.draw do
  root :to => 'application#index'

  # legacy routes
  get '/biografiya'                    => redirect('/ru/biografiya')
  get '/news/(*path)'                  => redirect('/ru/novosti')
  get '/words/(*path)'                 => redirect('/ru/pozitsiya/pozitsiya')
  get '/interview/(*path)'             => redirect('/ru/pozitsiya/intervyu')
  get '/photo/(*path)'                 => redirect('/ru/galereya/galereya')
  get '/photo-2012/(*path)'            => redirect('/ru/galereya/galereya/?parts_params[news_list][interval_year]=2012')
  get '/photo-2013/(*path)'            => redirect('/ru/galereya/galereya/?parts_params[news_list][interval_year]=2013')
  get '/photo-2014/(*path)'            => redirect('/ru/galereya/galereya/?parts_params[news_list][interval_year]=2014')
  get '/photo-krupnyimplanom/(*path)'  => redirect('/ru/galereya/krupnym-planom')
  get '/photo-archive/(*path)'         => redirect('/ru/galereya/arhiv')
  get '/video/(*path)'                 => redirect('/ru/video')
  get '/personal/(*path)'              => redirect('/ru/uvlecheniya')

  get '/(*path)', :to => 'application#index'

end
