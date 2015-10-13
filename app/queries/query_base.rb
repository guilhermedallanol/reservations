class QueryBase

  # delegate to new instance of query object, see
  # http://craftingruby.com/posts/2015/06/29/query-objects-through-scopes.html
  class << self
    delegate :call, to: :new
  end

  def initialize
    raise NotImplementedError
  end

  def call
    raise NotImplementedError
  end
end
