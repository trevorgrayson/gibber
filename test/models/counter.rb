class Counter
  @@count = 0

  class << self
    def inc
      @@count += 1
    end

    def count
      @@count
    end

    def reset 
      @@count = 0
    end
  end
end
