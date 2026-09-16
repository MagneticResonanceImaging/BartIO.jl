@testset "TV-regularized reconstruction" begin
    withenv("TOOLBOX_PATH" => nothing, "BART_GPU" => nothing) do
        # Periodic TV shrinks two equal plateaus by 2λ/width (two boundary jumps).
        width, λ = 4, 0.125f0
        image = repeat(vcat(zeros(ComplexF32, width), ones(ComplexF32, width)), 1, 2width)
        kspace = bart(1, "fft -u 3", image)
        sensitivity = ones(ComplexF32, size(image))
        shift = 2λ / width
        expected = shift .+ (1 - 2shift) .* image
        for gpu in ("CUDA" in ARGS ? ("", "-g") : ("",))
            reconstructed = bart(1, "pics $gpu -w 1 -m -R T:3:0:$λ -i 200", kspace, sensitivity; p=sensitivity)
            # Allow Float32 FFT/ADMM rounding: 32 eps in relative image norm, well below the TV shift.
            @test reconstructed ≈ expected rtol=32eps(Float32)
        end
    end
end
