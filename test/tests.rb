require 'rubygems'
require 'funkr/types'

include Funkr::Types

m = Maybe.just(5)

puts(m.match do |on|
       on.nothing{ Maybe.nothing }
       on.just{|v| Maybe.just(v + 1) }
     end.to_s)

puts(m.map{|v| v+1 })


n = Maybe.nothing

puts(n.match do |on|
       on.nothing{ Maybe.nothing }
       on.just{|v| Maybe.just(v + 1) }
     end.to_s)


puts "\n> Curry lift"
f = Maybe.curry_lift_proc{|x,y| x + y}
puts f.apply(m).apply(m)
puts f.apply(m).apply(n)
puts f.apply(m).apply(n.or_else{Maybe.just(10)})

puts "\n> Full lift"
f = Maybe.full_lift_proc{|x,y| x + y}
puts f.call(m,m)
puts f.call(m,n)

# puts Maybe.mconcat([Maybe.just(10),
#                     Maybe.just(20),
#                     Maybe.nothing,
#                     Maybe.just(30)])

puts(m <=> m)
puts(m <=> (m.map{|v| v+1}))
puts(m <= (m.map{|v| v+1}))
puts(m <=> n)
