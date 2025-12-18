# frozen_string_literal: true

class ApplicationService
  class << self
    def call(...)
      new(...).call(...)
    end
  end

  def call
    raise NotImplementedError, "You must define `call` as instance method in #{self.class.name} class"
  end
end
