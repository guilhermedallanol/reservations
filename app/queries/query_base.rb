class QueryBase

  def initialize
    raise NotImplementedError
  end

  def call
    raise NotImplementedError
  end
end
