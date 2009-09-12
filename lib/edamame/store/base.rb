# require 'monkeyshines/utils/factory_module'
module Edamame
  module Store
    class Base
      # The actual backing store; should respond to #set and #get methods
      attr_accessor :db

      def initialize options
      end

      #
      # Executes block once for each element in the whole DB, in whatever order
      # the DB thinks you should see it.
      #
      # Your block will see |key, val|
      #
      # key_store.each do |key, val|
      #   # ... stuff ...
      # end
      #
      def each &block
        db.iterinit
        loop do
          key = db.iternext or break
          val = db[key]
          yield key, val
        end
      end

      def each_as klass, &block
        self.each do |key, hsh|
          yield [key, klass.from_hash(hsh)]
        end
      end

      # Delegate to store
      def set(key, val)
        return unless val
        db.put key, val.to_hash.compact
      end
      def save obj
        return unless obj
        db.put obj.key, obj.to_hash.compact
      end

      def get(key)      db[key]         end
      def [](key)       get(key)        end
      def put(key, val) db.put key, val end
      def close()       db.close        end
      def size()        db.size         end
      def delete(key)   db.delete(key)  end

      #
      # Load from standard command-line options
      #
      # obvs only works when there's just one store
      #
      def self.create type, options
      end
    end
  end
end
