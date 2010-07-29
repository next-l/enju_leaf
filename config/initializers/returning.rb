class Object
  def returning(object, &block)
    tap do
      yield block
      return object
    end
  end
end
