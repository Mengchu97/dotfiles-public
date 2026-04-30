---
name: signal-processing
description: Statistical and digital signal processing algorithms, including spectral analysis, filter design, array processing, detection/estimation theory, and matrix computations in numpy/scipy.
---

## What I do

- Implement statistical signal processing algorithms (MVDR, LCMV, MUSIC, ESPRIT, CAPON)
- Design FIR/IIR filters (window method, Parks-McClellan, least-squares)
- Perform spectral analysis (periodogram, Welch, multitaper, STFT, wavelet)
- Write detection/estimation algorithms (MLE, MAP, GLRT, EM algorithm, Kalman filter)
- Handle complex-valued signal processing correctly in numpy/scipy
- Implement array signal processing (beamforming, DOA estimation, adaptive arrays)
- Compute performance bounds (Cramer-Rao Bound, Ziv-Zakai bound)
- Design and analyze sampling systems, quantization, and reconstruction

## Mathematical conventions

- Always verify matrix/vector dimensions before writing code. State dimensions explicitly in comments.
- Use `np.linalg.solve` instead of explicit matrix inversion whenever possible (numerical stability)
- For complex-valued operations, use `np.conj`, not manual conjugation; prefer `np.einsum` for tensor contractions
- When implementing algorithms from papers, cite the reference and equation number
- Distinguish between Hermitian transpose (`H`) and regular transpose (`T`) carefully
- Use `scipy.linalg` for structured matrix operations (Toeplitz, circulant, etc.)

## Common pitfalls to avoid

- Confusing correlation and covariance matrices (centered vs uncentered)
- Forgetting to handle the conjugate in complex-valued inner products
- Using `*` instead of `@` for matrix multiplication in Python
- Not normalizing frequency axes (0 to pi for discrete-time, 0 to fs/2 for continuous-time)
- Ignoring numerical conditioning when inverting near-singular matrices

## When to use me

Use this skill when implementing signal processing algorithms, statistical estimation, hypothesis testing, spectral estimation, beamforming, or any code involving heavy linear algebra and complex-valued computation.

Ask clarifying questions if:
- The signal model (real vs complex, discrete vs continuous) is ambiguous
- The noise model (AWGN, colored, impulsive) is unspecified
- The performance metric (SNR, MSE, probability of detection) is unclear
