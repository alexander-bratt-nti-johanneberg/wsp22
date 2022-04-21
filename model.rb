
def connect_to_db()
    db = SQLite3::Database.new('db/imdb.db')
    db.results_as_hash = true
    return db
end

def login_user(username, password)
    db = connect_to_db()
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    if result == nil
      redirect("https://www.youtube.com/watch?v=xvFZjo5PgG0")
    end
    pwdigest = result["pwdigest"]
    id = result["id"]
    auth = result["authorization"]
    
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      session[:auth] = auth
      redirect('/titles')
    else
      redirect("https://www.youtube.com/watch?v=xvFZjo5PgG0")
    end
end

def create_new_movie(producer_id, title, genre_id, user_id)
    db = connect_to_db()
    db.execute("INSERT INTO titles (name, producer_id, genre_id, user_id) VALUES (?,?,?,?)",title,producer_id,genre_id,user_id)
    redirect('/titles')
end

def delete_movie(id)
    db = connect_to_db()
    db.execute("DELETE FROM titles WHERE id = ?",id)
    redirect('/titles')
end

def register_user(username, password, password_confirm)
    
  if password == password_confirm && username.length <= 12
    password_digest = BCrypt::Password.create(password)
    authorization = 1
    db = connect_to_db()
    db.execute("INSERT INTO users (username,pwdigest,authorization) VALUES (?,?,?)",username,password_digest,authorization)
    redirect('/')

  else 

    "Användarnamnet är för långt/Lösenorden matchade inte."
  end
end

def edit_movie(id, title, producer_id)
    db = connect_to_db()
    db.execute("UPDATE titles SET name = ?, producer_id = ? WHERE id = ?", title, id, producer_id)
    redirect('/titles')
end

def rate_movie(title_id, rating, user_id)
    db = connect_to_db()
    db.execute("INSERT INTO users_titles (user_id,title_id,rating) VALUES (?,?,?)", user_id,title_id,rating).first
    redirect('/titles')
end

def goto_edit_movie(id)
    db = connect_to_db()
    result = db.execute("SELECT * FROM titles WHERE id = ?", id).first
end

def goto_rate_movie(id)
    db = connect_to_db()
    result = db.execute("SELECT * FROM titles WHERE id = ?", id).first
end

def fetch_all_movies()
    db = connect_to_db()
    db.execute("SELECT * FROM titles")
end

def fetch_movie(id)
    db = connect_to_db()
    db.execute("SELECT * FROM titles WHERE id = ?",id).first
end

def fetch_producer(id)
    db = connect_to_db()
    db.execute("SELECT producer_name FROM producers WHERE id IN (SELECT producer_id FROM titles WHERE id = ?)",id).first
end

def fetch_rating(id)
    db = connect_to_db()
    db.execute("SELECT AVG(rating) FROM users_titles WHERE title_id = ?", id).first
end

