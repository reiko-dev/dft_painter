class Fourier {
  Fourier({
    required this.freq,
    required this.amp,
    required this.re,
    required this.im,
    required this.phase,
  });
  final double amp, re, im, phase;
  final int freq;

  @override
  String toString() {
    return "Fourier(freq: ${freq.toStringAsFixed(1)}, "
        "amp: ${amp.toStringAsFixed(1)}, "
        "re: ${re.toStringAsFixed(1)}, "
        "im: ${im.toStringAsFixed(1)}, "
        "p: ${phase.toStringAsFixed(1)})";
  }
}
