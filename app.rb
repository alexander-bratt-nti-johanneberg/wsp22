require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
include Model
enable :sessions 

#Checks if user has permission to access paths
before do 
  if session[:id] == nil && (request.path_info != '/' && request.path_info != '/titles' && request.path_info != '/error' && request.path_info != '/showlogin' && request.path_info != '/register' && request.path_info !='/login')
    redirect('/error')
  end
end

#Displays error page
get('/error') do 
  slim(:error)
end

#Displays landing page
get('/') do
  redirect('/showlogin')
end

#Displays register form
get('/register') do
  slim(:register)
end

#Displays login form
get('/showlogin') do
  slim(:login)
end

#Logs user out by resetting sessions

# @session [Integer] :id, The client ID
# @session [Integer] :auth, The client authorization
get('/logout') do
  session[:id] = nil
  session[:auth] = nil
  redirect('/')
end

# Attempts to login user

# @param [String] :username, the user username
# @param [String] :password, the user password
# @loginResult[Boolean] :status, checks if user exists
post('/login') do
  if session[:timeLogged] == nil
    session[:timeLogged] = 0
  end

  logTime =  checkTime(session[:timeLogged])
  session[:timeLogged] = Time.now.to_i
  
  if logTime

    username = params[:username]
    password = params[:password]
    loginResult = login_user(username,password)
    if loginResult[:status] == true
      session[:id] = loginResult[:id]
      session[:auth] = loginResult[:auth]
      redirect('/titles')
    else 
      "Fel Användarnamn/lösenord"
    end
  else
    redirect('/showlogin')
  end
end

#Displays tilte page
get('/titles') do
  id = session[:id].to_i
  result = fetch_all_movies()
  slim(:"titles/index", locals:{titles:result})
end

#Displays new title form
get('/titles/new') do
    slim(:"titles/new")
end


#Attempts to create new title

# @param[Integer] :producer_id, The id of the producer
# @param[Integer] :title, Title
# @param[Integer] :genre_id, Genre Id
# @session[Integer] :id, Id of the creator of the title
post('/titles/') do
  producer_id = params[:producer_id].to_i
  title = params[:title]
  genre_id = params[:genre_id].to_i
  user_id = session[:id]
  create_new_movieResult = create_new_movie(producer_id, title, genre_id, user_id)

  if create_new_movieResult[:status] == true
    redirect('/titles')
  else 
    "FEL"
  end
end

#Attempts to delete title

# @param[Integer] :id, Id of the title

# @see Model#check_owner
# @see Model#delete_movie
post('/titles/:id/delete') do
  if session[:id] == nil || session[:auth] != 2
    redirect('/error')
  end
  id = params[:id].to_i
  owner = check_owner(id)
  if owner["user_id"] == session[:id]
    delete_movie(id)
    redirect('/titles')
  else
    "Du äger inte den här filmen!"
  end
end
#Attempts to create new user

# @param[String] :username, New user username
# @param[String] :password, New user password
# @param[String] :password_confim, Checks if both passwords are the same

# @see Model#register_user
# @see Model#checkTime

post('/users/') do
  if session[:timeLogged] == nil
    session[:timeLogged] = 0
  end

  logTime =  checkTime(session[:timeLogged])
  session[:timeLogged] = Time.now.to_i
  
  if logTime

    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    registerResult = register_user(username, password, password_confirm)
    if registerResult[:status] == true
      redirect('/')
    else 
      "Användarnamnet/Lösenord är för långt/Lösenorden matchade inte."
    end
  else
    redirect('/register')
  end
end

#Displays title edit form

# @see Model#goto_edit_movie
get('/titles/:id/edit') do
  if session[:id] == nil || session[:auth] != 2
    redirect('/error')
  end
  id = params[:id].to_i
  result = goto_edit_movie(id)
  slim(:"/titles/edit", locals:{result:result})
end

# Attempts to update title

# @param [String] :title, Title name
# @param [Integer] :ProducerId, Id of producer
# @param [Integer] :GenreId, Id of genre

# @see Model#edit_movie

post('/titles/:id/update') do
  id = params[:id].to_i
  title = params[:title]
  producer_id = params[:ProducerId]
  genre_id = params[:GenreId]
  edit_movieResult = edit_movie(id, title, producer_id, genre_id)
  if edit_movieResult[:status] == true
    redirect('/titles')
  else
    "Du har gjort fel"
  end
end

#Displays title

# @see Model#fetch_movie
# @see Model#fetch_genre
# @see Model#fetch_producer
# @see Model#fetch_rating

get('/titles/:id') do
  id = params[:id]
  result = fetch_movie(id)
  genre = fetch_genre(id)
  producer = fetch_producer(id)
  rating = fetch_rating(id)
  slim(:"titles/show",locals:{result:result,producer:producer,rating:rating,genre:genre})
end

#Displays title rating form

get('/titles/:id/rate') do
  if session[:id] == nil
    redirect('/error')
  end
  id = params[:id].to_i
  user_id = session[:id]
  result = goto_rate_movie(id)
  slim(:"titles/rate",locals:{result:result})
end

#Attempts to rate title

# @param [Integer] :id, Title id
# @param [Integer] :rating, Rating of title
# @see Model#rate_movie

post('/titles/:id/rated') do
  title_id = params[:id].to_i
  rating = params[:rating].to_i
  user_id = session[:id]
  rate_movieResult = rate_movie(title_id, rating, user_id)
  if rate_movieResult[:status] == true
    redirect('/titles')
  else
    "Rating Större än 10/Du har inte använt en siffra"
  end
end