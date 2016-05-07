module Ripa

  # An interface for a collection of query and command endpoints.
  class Client

    # Call a query endpoint with query structure `q` of type
    # Ripa::DataTypes::Query.
    #
    # Returns a Result object representing the result.
    #
    # Dispatching to an implementation is based on the value of
    # `:endpoint` key in the `q` query structure and optionally also
    # by other parameters in `q` if a logical query endpoint is
    # implemented by multiple backing endpoints.
    def query(q)
      raise StandardError.new("Not implemented")
    end

    # Invoke a command. The result of the operation is returned as a
    # Result object. Invoking a command can cause arbitrary
    # side-effects. If the side effects are triggered asynchronously
    # the result value will represent only the result of the "main"
    # computation and other side effects have their own lifecycles and
    # retry semantics.
    def command(c)
      raise StandardError.new("Not implemented")
    end
  end
end
