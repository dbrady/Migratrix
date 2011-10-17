require 'active_model/attribute_methods'

module Migratrix
  # Superclass for all migrations. Migratrix COULD check to see that a
  # loaded migration inherits from this class, but hey, duck typing.
  class Migration
    include ::Migratrix::Loggable
    include ActiveModel::AttributeMethods

    cattr_accessor :extractor
    attr_accessor :options

    def initialize(options={})
      @options = options.deep_copy
    end

    # Adds an extractor to the extractors chain.
    def self.set_extractor(name, options={})
      # klassify this name
      raise NotImplementedError.new("Migratrix currently only supports ActiveRecord extractor.") unless name == :active_record
      @@extractor = ::Migratrix::Extractors::ActiveRecord.new(options)
    end

    def extractor
      @@extractor
    end

    # OKAY, NEW RULE: You get ONE Extractor per Migration. You're
    # allowed to have multiple transform/load chains to the
    # extraction, but extractors? ONE.

    # default extraction method; simply assigns @extractor.extract to
    # @extracted_items. If you override this method, you should
    # populate @extracted_items if you want the default transform
    # and/or load to work correctly.
    def extract
      extractor.extract(options)
    end

    # Transforms source data into outputs
    def transform
      # run the chain of transforms
    end

    # Saves the migrated data by "loading" it into our database or
    # other data sink.
    def load
      # run the chain of loads
    end

    # Perform the migration
    # TODO: turn this into a strategy object. This pattern migrates
    # everything in all one go, while the user may want to do a batch
    # strategy. YAGNI: Rails 3 lets us defer the querying until we get
    # to the transform step, and then it's batched for us under the
    # hood. ...assuming, of course, we change the ActiveRecord
    # extractor's execute_extract method to return source instead of
    # all, but now the
    def migrate
      @extracted_items = extract
      transform
      load
    end
  end
end

