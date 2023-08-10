using jlookc
using Test
using DelimitedFiles

@testset "jlookc.jl" begin

  # Just one integration test: does it get the same answer as the R code?
  println(pwd())
  looks2 = jlookc.loadCompactLooks( "../data/test_save_looks")
  from_compact = jlookc.formAllLooks(looks2["knockoffs"], looks2["vars_to_omit"], looks2["updates"])
  from_r = [readdlm("../data/test_save_looks_full/" * string(i) * ".csv", ',', header = true)[1] for i in 1:10]
  for k in 1:length(from_r)
    @test sum( broadcast(abs, from_compact[k] - from_r[k] ) ) < 1e-10
  end

end
