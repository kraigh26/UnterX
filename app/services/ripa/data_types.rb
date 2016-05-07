module Ripa
  module DataTypes
    Query = EntityUtils.define_builder(
      # Name of the logical endpoint being queried. Defines the main
      # response resource type and typically matches with it
      # (e.g. :listings, :marketplaces, etc.)
      [:endpoint, :mandatory, :symbol],

      # An optional id. If a value for id is defined the return type
      # of the query is a single resource document. If the id is not
      # defined, the return type is a collection of resource
      # documents.
      [:id, :string],

      # Hash of filter parameters, endpoint specific language. Each
      # endpont defines the set of filter parameters (and types for
      # those) that it supports.
      [:filter, :hash],

      # An array of symbols identifying a set of resources for
      # inclusion. Each endpoint defines which relationships it
      # supports for inclusion. Calling with an unsupported resource
      # type is an error.
      [:include, :array],

      # For limiting the fields included in resource documents. A hash
      # from resource type to an array of symbols where each symbol
      # names a field. The behaviour is to limit so for each resource
      # type that fields hash is omitted a default set of fields (as defined by
      # resource type schema) is returned.
      [:fields, :hash])


    module_function

    def create_query(opts)
      Query.call(opts)
    end

  end
end
