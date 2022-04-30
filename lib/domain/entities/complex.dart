class Complex {
  dynamic re, im;

  Complex(this.re, this.im);

  mult(c) {
    final re = this.re * c.re - this.im * c.im;
    final im = this.re * c.im + this.im * c.re;

    return Complex(re, im);
  }

  add(c) {
    re += c.re;
    im += c.im;
  }
}
