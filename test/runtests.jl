using BayesHistogram, Test, Random, StableRNGs

@testset "basic test BayesHistogram" begin
    x = randn(StableRNG(1337), 5000)

    ref = [
           -3.1578070050937224,
           -2.627589003399208,
           -2.1567159913141696,
           -1.809553033077446,
           -1.4561209721822812,
           -0.9972606510660637,
           -0.5753838312589055,
           0.8030403893027767,
           1.1970293913971268,
           1.6398624165469307,
           2.104886260600142,
           2.498821309397118,
           2.92140180959945,
           3.8845391427592286,
          ]
    @test all(bayesian_blocks(x, resolution = 100.0, min_counts = 2).edges .≈ ref)

    ref = [
           -3.1578070050937224,
           -2.4424726736043123,
           -1.719768706521348,
           -0.9972606510660637,
           0.9593283778530831,
           1.6649014185653361,
           2.498821309397118,
           3.8845391427592286,
          ]
    @test all(bayesian_blocks(x, resolution = 10.0, min_counts = 2).edges .≈ ref)

    ref = [
           -3.1578070050937224,
           -2.4004600598649937,
           -1.8298532494637834,
           -1.3500184449043653,
           -0.8774030758210719,
           -0.23294418890701424,
           0.3779185031870537,
           0.9593283778530831,
           1.4851079736094,
           1.965053158543435,
           2.4534081553862954,
           3.8845391427592286,
    ]
    @test all(bayesian_blocks(x, resolution = 15.0).edges .≈ ref)


    w = rand(StableRNG(1337), 5000) .* 10 .+ 10
    ref = [
           -3.1578070050937224,
           -1.5449036608365123,
           1.0655876974876393,
           2.474272965955527,
           3.8845391427592286,
          ]
    @test all(bayesian_blocks(x, weights = w, resolution = 5.0).edges .≈ ref)
    
    ref = [
           -3.1578070050937224,
           -2.627589003399208,
           -2.4424726736043123,
           -2.1567159913141696,
           -2.007312256358908,
           -1.8298532494637834,
           -1.672177926449848,
           -1.4561209721822812,
           -1.2629080974042246,
           -0.9991635954562337,
           -0.7973904890758701,
           -0.5753838312589055,
           -0.4286389710947635,
           -0.23354006071343802,
           -0.08731284637243833,
           0.10695053261983944,
           0.3779185031870537,
           0.5255797020151315,
           0.8030403893027767,
           0.9449575195349826,
           1.1970293913971268,
           1.5203188316842984,
           1.7117859538444158,
           1.9626991729085734,
           2.104886260600142,
           2.2470590206020926,
           2.498821309397118,
           2.8530173295282495,
           3.8845391427592286,
          ]

    @test all(bayesian_blocks(x, weights = w, resolution = 50.0).edges .≈ ref)
end



@testset "Jeffrey's Prior" begin
    max_N = 100
    Nv = 1:max_N
    prior = @. 1/sqrt(Nv)
    prior .= log.(prior./sum(prior))
    a_prior = Jeffrey(1.0)
    deltas = abs.(prior .- a_prior.(Nv, max_N))
    @test all(deltas .<= 1e-10)
end


@testset "Robustness" begin
    tries = 100
    fails = 0
    okays = 0
    for i in 1:tries
        x = randn(StableRNG(1337 + 137*i), 500)
        try
            bl = bayesian_blocks(x)
            okays += 1
        catch all
            fails += 1
        end
    end
    @test fails == 0
    @test okays == tries
end

@testset "Integer inputs" begin
    input_int = round.(Int, randn(1000) * 100)
    input_float = float.(input_int)
    @test bayesian_blocks(input_int) == bayesian_blocks(input_float)
end

