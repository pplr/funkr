require 'funkr/adt/adt'
require 'funkr/categories'

module Funkr
  module Types
    class Maybe < ADT

      include Funkr::Categories

      adt :just, :nothing

      ### Categories

      include Functor

      def map(&block)
        self.match do |on|
          on.just {|v| self.class.just(yield(v))}
          on.nothing { self }
        end
      end

      # Maybe can be made an applicative functor, for example :
      # f = Maybe.curry_lift_proc{|x,y| x + y}
      # a = Maybe.just(3)
      # b = Maybe.just(4)
      # c = Maybe.nothing
      # f.apply(a).apply(b) => Just 7
      # f.apply(a).apply(c) => Nothing
      include Applicative
      extend Applicative::ClassMethods

      def apply(to)
        self.match do |f_on|
          f_on.just do |f|
            to.match do |t_on|
              t_on.just {|t| self.class.unit(f.call(t)) }
              t_on.nothing { to }
            end
          end
          f_on.nothing { self }
        end
      end

      include Alternative

      def or_else(&block)
        self.match do |on|
          on.just {|v| self}
          on.nothing { yield }
        end
      end


      include Monoid
      extend Monoid::ClassMethods

      def mplus(m_y)
        self.match do |x_on|
          x_on.nothing { m_y }
          x_on.just do |x|
            m_y.match do |y_on|
              y_on.nothing { self }
              y_on.just {|y| self.class.just(x.mplus(y))}
            end
          end
        end
      end


      include Monad
      extend Monad::ClassMethods

      def bind(&block)
        self.match do |on|
          on.just {|v| yield(v)}
          on.nothing {self}
        end
      end

      def unbox(default=nil)
        self.match do |on|
          on.just {|v| v }
          on.nothing { default }
        end
      end

      class << self
        alias unit just
        alias pure just
        alias mzero nothing
      end

      def self.box(value)
        if value.nil? then self.nothing
        else self.just(value) end
      end

      # concat :: [Maybe a] -> [a]
      #  The Maybe.concat function takes a list of Maybes and returns
      #  a list of all the Just values.
      def self.concat(maybes)
        maybes.inject([]) do |a, e|
          e.match do |on|
            on.just{|v| a + [v]}
            on.nothing{ a }
          end
        end
      end

    end
  end
end
