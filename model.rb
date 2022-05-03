module Model
  
  def connect_to_db()
      db = SQLite3::Database.new('db/imdb.db')
      db.results_as_hash = true
      return db
  end

  def login_user(username, password)
      db = connect_to_db()
      result = db.execute("SELECT * FROM users WHERE username = ?",username).first
      if result == nil
        return {status:false}
      end
      pwdigest = result["pwdigest"]
      id = result["id"]
      auth = result["authorization"]

      if BCrypt::Password.new(pwdigest) == password
        return {id:id, auth:auth, status:true}
      else
        return {status:false}
      end
  end

  def create_new_movie(producer_id, title, genre_id, user_id)
      db = connect_to_db()
      if title.length <= 20 && (producer_id <= 2 || producer_id > 0)  && (genre_id <= 3 || genre_id > 0)
        db.execute("INSERT INTO titles (name, producer_id, genre_id, user_id) VALUES (?,?,?,?)",title,producer_id,genre_id,user_id)
        return {status:true}
      else
        return {status:false}
      end
  end
  def check_owner(id)
      db = connect_to_db()
      db.execute("SELECT user_id FROM titles WHERE id = ?", id).first
  end

  def delete_movie(id)
      db = connect_to_db()
      db.execute("DELETE FROM titles WHERE id = ?",id)
      db.execute("DELETE FROM users_titles WHERE title_id = ?",id)
  end

  def register_user(username, password, password_confirm)

    if (password == password_confirm && password.length <= 12 && password.length > 0) && (username.length > 0 && username.length <= 12 )
      password_digest = BCrypt::Password.create(password)
      authorization = 1
      db = connect_to_db()
      db.execute("INSERT INTO users (username,pwdigest,authorization) VALUES (?,?,?)",username,password_digest,authorization)
      return {status:true}
    else 
      return {status:false}
    end
  end

  def edit_movie(id, title, producer_id, genre_id)
      db = connect_to_db()
      if title.length <= 20 && (producer_id <= 2 || producer_id > 0)  && (genre_id <= 3 || genre_id > 0)
        db.execute("UPDATE titles SET name = ?, producer_id = ?, genre_id = ? WHERE id = ?", title, id, producer_id, genre_id)
        return {status:true}
      else
        return {status:false}
      end
  end

  def rate_movie(title_id, rating, user_id)
      db = connect_to_db()
      if rating <= 10 && rating.class == Integer
        db.execute("INSERT INTO users_titles (user_id,title_id,rating) VALUES (?,?,?)", user_id,title_id,rating).first
        return {status:true}
      else
        return {status:false}
      end
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
  
end

def checkTime(latestTime)

  timeDiff = Time.now.to_i - latestTime

  return timeDiff > 1.5

end
