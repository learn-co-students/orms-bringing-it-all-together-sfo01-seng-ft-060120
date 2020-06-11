require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize (id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def save
        if self.id
            self.update
            self
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?;
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def self.create(attributes)
       dog = self.new(attributes)
       dog.save
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?;
        SQL
        dog = DB[:conn].execute(sql, id)[0]
        new_dog = self.new_from_db(dog)
        new_dog
    end

    def self.find_or_create_by(attributes)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", attributes.values[0], attributes.values[1])
        if !dog.empty?
            new_dog = self.new_from_db(dog[0])
        else 
            new_dog = self.create(attributes)
        end
        new_dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        new_dog = self.new_from_db(dog[0])
        new_dog
    end
end