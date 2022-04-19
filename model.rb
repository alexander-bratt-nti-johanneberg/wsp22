
def connect_to_db()
    db = SQLite3::Database.new('db/imdb.db')
    db.results_as_hash = true
    return db
end

def register_user