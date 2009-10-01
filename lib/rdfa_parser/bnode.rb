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

    ## 
    # Exports the BNode in N-Triples form.
    #
    # ==== Example
    #   b = BNode.new; b.to_n3  # => returns a string of the BNode in n3 form
    #
    # ==== Returns
    # @return [String] The BNode in n3.
    #
    # @author Tom Morris

    def to_n3
      "_:#{self.identifier}"
    end

    ## 
    # Exports the BNode in N-Triples form.
    #
    # ==== Example
    #   b = BNode.new; b.to_ntriples  # => returns a string of the BNode in N-Triples form
    #
    # ==== Returns
    # @return [String] The BNode in N-Triples.
    #
    # @author Tom Morris

    def to_ntriples
      self.to_n3
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
