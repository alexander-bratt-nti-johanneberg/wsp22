module Model
  #Attempts to open a new database connection

  # @return [Array] containing all the data from the database
  def connect_to_db()
      db = SQLite3::Database.new('db/imdb.db')
      db.results_as_hash = true
      return db
  end
  #Attempts to check if user can login
  # @return [Hash] returns hash if password is correct

  # @see Model#connect_t_db
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

  #Attempts to create new movie
  # @see Model#connect_to_db
  # @return [Hash] returns hash if Boolean == true or false

  def create_new_movie(producer_id, title, genre_id, user_id)
      db = connect_to_db()
      if title.length <= 20
        db.execute("INSERT INTO titles (name, producer_id, genre_id, user_id) VALUES (?,?,?,?)",title,producer_id,genre_id,user_id)
        return {status:true}
      else
        return {status:false}
      end
  end

  #Attempts to check if User is owner of movie
  # @see Model#connect_to_db
  def check_owner(id)
      db = connect_to_db()
      db.execute("SELECT user_id FROM titles WHERE id = ?", id).first
  end

  #Attempts to delete movie
  # @see Model#connect_to_db
  def delete_movie(id)
      db = connect_to_db()
      db.execute("DELETE FROM titles WHERE id = ?",id)
      db.execute("DELETE FROM users_titles WHERE title_id = ?",id)
  end

  #Attempts to register new user
  # @see Model#connect_to_db
  # @return [Hash] returns hash if boolean == true or false
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

  #Attempts to edit existing movie
  # @see Model#connect_to_db
  # @return [Hash] returns has if boolean == true or false
  def edit_movie(id, title, producer_id, genre_id)
      db = connect_to_db()
      if title.length <= 20 
        db.execute("UPDATE titles SET name = ? WHERE id = ?", title, id)
        db.execute("UPDATE titles SET producer_id = ? WHERE id = ?", producer_id, id)
        db.execute("UPDATE titles SET genre_id = ? WHERE id = ?", genre_id, id)
        return {status:true}
      else
        return {status:false}
      end
  end

  #Attempts to rate movie
  # @see Model#connect_to_db
  # @return [Hash] returns if boolean == true or false
  def rate_movie(title_id, rating, user_id)
      db = connect_to_db()
      if rating <= 10 && rating.class == Integer
        db.execute("INSERT INTO users_titles (user_id,title_id,rating) VALUES (?,?,?)", user_id,title_id,rating).first
        return {status:true}
      else
        return {status:false}
      end
  end

  #Attempts to go to edit movie form
  # @see Model#connect_to_db 
  def goto_edit_movie(id)
      db = connect_to_db()
      result = db.execute("SELECT * FROM titles WHERE id = ?", id).first
  end
  #Attempts to go to rate movie form
  # @see Model#connect_to_db

  def goto_rate_movie(id)
      db = connect_to_db()
      result = db.execute("SELECT * FROM titles WHERE id = ?", id).first
  end

  #Attempts to get all movies 
  # @see Model#connect_to_db

  def fetch_all_movies()
      db = connect_to_db()
      db.execute("SELECT * FROM titles")
  end

  #Attempts to get specific movie
  # @see Model#connect_to_db

  def fetch_movie(id)
      db = connect_to_db()
      db.execute("SELECT * FROM titles WHERE id = ?",id).first
  end

  #Attempts to get specific producer
  # @see Model#connect_to_db
  def fetch_producer(id)
      db = connect_to_db()
      db.execute("SELECT producer_name FROM producers WHERE id IN (SELECT producer_id FROM titles WHERE id = ?)",id).first
  end

  #Attempts to get specific genre
  # @see Model#connect_to_db
  def fetch_genre(id)
      db = connect_to_db()
      db.execute("SELECT genre_name FROM genre WHERE id IN (SELECT genre_id FROM titles WHERE id = ?)", id).first
  end

  #Attempts to get specific rating
  # @see Model#connect_to_db

  def fetch_rating(id)
      db = connect_to_db()
      db.execute("SELECT AVG(rating) FROM users_titles WHERE title_id = ?", id).first
  end
  
  # Logs time 
  # @return [Boolean] checks if timeDiff is bigger than Integer

  def checkTime(latestTime)

    timeDiff = Time.now.to_i - latestTime

    return timeDiff > 1.5

  end

  

end
