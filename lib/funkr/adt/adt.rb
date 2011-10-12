require "funkr/adt/matcher"

module Funkr

  # Very rought Algebraic Data Types. A class inheriting from ADT can
  # declare constructors with #adt
  class ADT

    def initialize(const, *data)
      @const, @data = const, data
    end

    # Declare ADT constructors, for example :
    # class Maybe < ADT;  adt :just, :nothing; end
    def self.adt(*constructs)
      build_adt(constructs)
      build_matcher(constructs)
    end

    def self.matcher; @matcher; end
    
    # Match your ADT against its constructors, for example :
    # a = Maybe.just("hello")
    # a.match do |on|
    #   on.just{|x| puts x}
    #   on.nothing{ }
    # end
    def match
      m = self.class.matcher.new(normal_form)
      yield m
      m.run_match
    end
    
    def to_s
      format("{%s%s%s}",
             @const,
             @data.any? ? " : " : "",
             @data.map(&:inspect).join(", ") )
    end
    
    private

    attr_reader :const, :data
    
    def normal_form; [@const, *@data]; end
    
    def self.build_adt(constructs)
      constructs.each do |c,*d|
        define_singleton_method(c) do |*data|
          self.new(c,*data)
        end
        define_method(format("%s?",c).to_sym) do
          const() == c
        end
      end
    end
    
    def self.build_matcher(constructs)
      @matcher = Class.new(Funkr::Matcher) do
        build_matchers(constructs)
      end
    end

  end
end
