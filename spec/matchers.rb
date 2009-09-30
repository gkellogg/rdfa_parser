module Matchers
  class BeEquivalentGraph
    def initialize(expected, info)
      @expected = expected
      @info = info
    end
    def matches?(actual)
      @actual = actual
      @last_line = 0
      @sorted_actual = @actual.triples.sort_by{|t| t.to_ntriples}
      @sorted_expected = @expected.triples.sort_by{|t| t.to_ntriples}
      0.upto(@sorted_actual.length) do |i|
        @last_line = i
        a = @sorted_actual[i]
        b = @sorted_expected[i]
        return false unless a == b
      end
      @sorted_actual.length == @sorted_expected.length
    end
    def failure_message_for_should
      if @last_line < @sorted_actual.length && @sorted_expected[@last_line]
        "Graph differs at entry #{@last_line}:\nexpected: #{@sorted_expected[@last_line].to_ntriples}\nactual:   #{@sorted_actual[@last_line].to_ntriples}"
      elsif @last_line < @actual.triples.length
        "Graph differs at entry #{@last_line}:\nunexpected: #{@sorted_actual[@last_line].to_ntriples}"
      else
        "Graph entry count differs:\nexpected: #{@sorted_expected.length}\nactual:   #{@sorted_actual.length}"
      end +
      "\n\n#{@info}" +
      "\nUnsorted Expected:\n#{@expected.to_ntriples}" +
      "Unsorted Results:\n#{@actual.to_ntriples}"
    end
  end
  
  def be_equivalent_graph(expected, info = "")
    BeEquivalentGraph.new(expected, info)
  end

  # Run expected SPARQL query against actual
  class PassQuery
    def initialize(expected, info)
      @expected = expected
      @query = Redland::Query.new(expected)
      @info = info
    end
    def matches?(actual)
      @actual = actual
      model = Redland::Model.new
      ntriples_parser = Redland::Parser.ntriples
      ntriples_parser.parse_string_into_model(model, actual.to_ntriples, "http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/")

      @results = @query.execute(model)
      if @expected.match(/(This test should result in a 'NO'|negative test case)/)
        @results.nil? || (@results.is_boolean? && !@results.get_boolean?)
      else
        @results.is_boolean? && @results.get_boolean?
      end
    end
    def failure_message_for_should
      @info + ":\n" +
      if @results.nil?
        "Query failed to return results"
      elsif !@results.is_boolean?
        "Query returned non-boolean results"
      else
        "Query returned false"
      end +
      "\n#{@expected}" +
      "\nResults:\n#{@actual.to_ntriples}"
    end
  end

  def pass_query(expected, info = "")
    PassQuery.new(expected, info)
  end
end
