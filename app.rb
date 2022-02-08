require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions 

get('/') do
  slim(:register)
end

get('/showlogin') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/imdb.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result["pwdigest"]
  id = result["id"]
  
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/titles')
  else
    "FEL DU HAR FEL LÖSEN"
  end
end

get('/titles') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/imdb.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM titles WHERE user_id = ?", id)
  p "Alla titlar från result #{result}"
  slim(:"titles/index", locals:{titles:result})
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/imdb.db')
    db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
    redirect('/')

  else 

    "lösenorden matchade inte"
  end
end