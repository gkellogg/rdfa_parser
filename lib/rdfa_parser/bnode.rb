module RdfaParser
  # The BNode class creates RDF blank nodes.
  class BNode
    @@next_generated = "a"
    @@named_nodes = {}
    
    # Create a new BNode, optionally accept a identifier for the BNode. Otherwise, generated sequentially
    def initialize(identifier = nil)
      if identifier != nil && self.valid_id?(identifier)
        # Generate a name if it's blank
        @identifier = (@@named_nodes[identifier] ||= identifier.to_s.length > 0 ? identifier : self )
      else
        # Don't actually allocate the name until it's used, to save generation space
        # (and make checking test cases easier)
        @identifier = self
      end
    end

    def to_s
      return self.identifier.to_s
    end

    # BNode serialization in _:identifier format
    def to_ntriples
      "_:#{self.to_s}"
    end

    # The identifier used used for this BNode. Not evaluated until this is called, which means
    # that BNodes that are never used in a triple won't polute the sequence.
    def identifier
      return @identifier unless @identifier.is_a?(BNode)
      if @identifier.equal?(self)
        # Generate from the sequence a..zzz, unless already taken
        @@next_generated = @@next_generated.succ while @@named_nodes.has_key?(@@next_generated)
        @identifier, @@next_generated = @@next_generated, @@next_generated.succ
      else
        # Previously allocated node
        @identifier = @identifier.identifier
      end
      @identifier
    end
    
    def eql?(other)
      other.is_a?(self.class) && self.identifier == other.identifier
    end
    alias_method :==, :eql?
    
    # Start _identifier_ sequence from scratch
    def self.reset(init = "a")
      @@next_generated = init
      @@named_nodes = {}
    end

    protected
    def valid_id?(name)
      name =~ /^[a-zA-Z_][a-zA-Z0-9]*$/
    end
  end
end
