require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions 

get('/') do
  slim(:login)
end

get('/register') do
  slim(:register)
end

get('/showlogin') do
  slim(:login)
end

get('/logout') do
  session[:id] = nil
  redirect('/')
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/imdb.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  if result == nil
    redirect("https://www.youtube.com/watch?v=xvFZjo5PgG0")
  end
  pwdigest = result["pwdigest"]
  id = result["id"]
  
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/titles')
  else
    redirect("https://www.youtube.com/watch?v=xvFZjo5PgG0")
  end
end

get('/titles') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/imdb.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM titles WHERE user_id = ?", id)
  slim(:"titles/index", locals:{titles:result})
end

get('/titles/new') do
    slim(:"titles/new")
end

post('/titles/new') do
    title = params[:title]
    producer_id = params[:producer_id].to_i
    genre_id = params[:genre_id].to_i
    user_id = session[:id]
    db = SQLite3::Database.new("db/imdb.db")
    db.execute("INSERT INTO titles (name, producer_id, genre_id, user_id) VALUES (?,?,?,?)",title,producer_id,genre_id,user_id)
    redirect('/titles')
end

post('/titles/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/imdb.db")
  db.execute("DELETE FROM titles WHERE id = ?",id)
  redirect('/titles')
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm && username.length <= 12
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/imdb.db')
    db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
    redirect('/')

  else 

    "Användarnamnet är för långt/Lösenorden matchade inte."
  end
end


get('/titles/:id/edit') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/imdb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM titles WHERE id = ?", id).first
  slim(:"/titles/edit", locals:{result:result})
end

post('/titles/:id/update') do
  id = params[:id].to_i
  title = params[:title]
  producer_id = params[:ProducerId]
  db = SQLite3::Database.new("db/imdb.db")
  db.execute("UPDATE titles SET name = ?, producer_id = ? WHERE id = ?", title, id, producer_id)
  redirect('/titles')
end

get('/titles/:id') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/imdb.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM titles WHERE id = ?",id).first
  result2 = db.execute("SELECT producer_name FROM producers WHERE id IN (SELECT producer_id FROM titles WHERE id = ?)",id).first
  slim(:"titles/show",locals:{result:result,result2:result2})
end

get('/titles/:id/rate') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/imdb.db")
  user_id = session[:id]
  db.results_as_hash = true
  result = db.execute("SELECT * FROM titles WHERE id = ?", id).first
  slim(:"titles/rate",locals:{result:result})
end

