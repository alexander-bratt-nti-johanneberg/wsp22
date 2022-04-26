require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
include Model
enable :sessions 


before ('/titles/:id/rate') do
  if session[:id] == nil
    redirect('/error')
  end
end

before ('/titles/:id/edit') do
  if session[:id] == nil || session[:auth] != 2
    redirect('/error')
  end
end

before ('/titles/:id/delete') do
  if session[:id] == nil || session[:auth] != 2
    redirect('/error')
  end
end

before ('/titles/new') do
  if session[:id] == nil
    redirect('/error')
  end
end

get('/error') do 
  slim(:error)
end

get('/') do
  redirect('/showlogin')
end

get('/register') do
  slim(:register)
end

get('/showlogin') do
  slim(:login)
end

get('/logout') do
  session[:id] = nil
  session[:auth] = nil
  redirect('/')
end

post('/login') do
  username = params[:username]
  password = params[:password]
  login_user(username,password)
end

get('/titles') do
  id = session[:id].to_i
  result = fetch_all_movies()
  slim(:"titles/index", locals:{titles:result})
end

get('/titles/new') do
    slim(:"titles/new")
end

post('/titles/new') do
  producer_id = params[:producer_id].to_i
  title = params[:title]
  genre_id = params[:genre_id].to_i
  user_id = session[:id]
  create_new_movie(producer_id, title, genre_id, user_id)
end

post('/titles/:id/delete') do
  id = params[:id].to_i
  delete_movie(id)
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  register_user(username, password, password_confirm)
end


get('/titles/:id/edit') do
  id = params[:id].to_i
  result = goto_edit_movie(id)
  slim(:"/titles/edit", locals:{result:result})
end

post('/titles/:id/update') do
  id = params[:id].to_i
  title = params[:title]
  producer_id = params[:ProducerId]
  edit_movie(id, title, producer_id)
end

get('/titles/:id') do
  id = params[:id]
  result = fetch_movie(id)
  producer = fetch_producer(id)
  rating = fetch_rating(id)
  slim(:"titles/show",locals:{result:result,producer:producer,rating:rating})
end

get('/titles/:id/rate') do
  id = params[:id].to_i
  user_id = session[:id]
  result = goto_rate_movie(id)
  slim(:"titles/rate",locals:{result:result})
end

post('/titles/:id/rated') do
  title_id = params[:id].to_i
  rating = params[:rating].to_i
  user_id = session[:id]
  rate_movie(title_id, rating, user_id)
end