require 'pstore'

class Base
  class << self
    def find(id)
      db.transaction(true) do
        db[db_id(id)]
      end
    end

    def all
      db.transaction(true) do
        db.roots
          .select { |key| key.start_with?(self.name) }
          .map { |key| db[key] }
      end
    end

    def db
      @db ||= PStore.new("db.pstore")
    end

    def db_id(base)
      "#{self.name}_#{base}"
    end

    def next_available_id
      all.sort_by(&:id).last.id + 1
    end
  end


  def save
    ensure_id
    self.class.db.transaction do |db|
      db[db_id] = self
    end
  end


  def db_id
    self.class.db_id(id)
  end


  def ensure_id
    self.id ||= self.class.next_available_id
  end
end
