# Funciones de distribución y álgebra lineal que usan las calculadoras.
module Estadistica
  module_function

  # ── Normal estándar ──────────────────────────────────────────────────────────
  def normal_cdf(z)
    0.5 * Math.erfc(-z / Math.sqrt(2))
  end

  def normal_inv(p)
    raise ArgumentError, 'p debe estar entre 0 y 1' unless p > 0 && p < 1
    biseccion(p, -40.0, 40.0) { |z| normal_cdf(z) }
  end

  # ── Beta incompleta regularizada (base para t y F) ───────────────────────────
  def beta_cf(x, a, b)
    fpmin = 1e-300
    qab = a + b
    qap = a + 1
    qam = a - 1
    c = 1.0
    d = 1 - qab * x / qap
    d = fpmin if d.abs < fpmin
    d = 1 / d
    h = d
    (1..300).each do |m|
      m2 = 2 * m
      aa = m * (b - m) * x / ((qam + m2) * (a + m2))
      d = 1 + aa * d
      d = fpmin if d.abs < fpmin
      c = 1 + aa / c
      c = fpmin if c.abs < fpmin
      d = 1 / d
      h *= d * c
      aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
      d = 1 + aa * d
      d = fpmin if d.abs < fpmin
      c = 1 + aa / c
      c = fpmin if c.abs < fpmin
      d = 1 / d
      del = d * c
      h *= del
      break if (del - 1).abs < 1e-15
    end
    h
  end

  def ibeta(x, a, b)
    return 0.0 if x <= 0
    return 1.0 if x >= 1
    lbeta = Math.lgamma(a)[0] + Math.lgamma(b)[0] - Math.lgamma(a + b)[0]
    front = Math.exp(Math.log(x) * a + Math.log(1 - x) * b - lbeta)
    if x < (a + 1) / (a + b + 2)
      front * beta_cf(x, a, b) / a
    else
      1 - front * beta_cf(1 - x, b, a) / b
    end
  end

  # ── t de Student ─────────────────────────────────────────────────────────────
  def t_cdf(t, gl)
    return t.positive? ? 1.0 : 0.0 if t.infinite?
    t = t.to_f
    gl = gl.to_f
    cola = 0.5 * ibeta(gl / (gl + t * t), gl / 2.0, 0.5)
    t >= 0 ? 1 - cola : cola
  end

  def t_inv(p, gl)
    raise ArgumentError, 'p debe estar entre 0 y 1' unless p > 0 && p < 1
    lim = 1.0
    lim *= 2 while t_cdf(lim, gl) < p || t_cdf(-lim, gl) > p
    biseccion(p, -lim, lim) { |t| t_cdf(t, gl) }
  end

  # P(|T| ≥ |t|)
  def t_p_dos_colas(t, gl)
    return 0.0 if t.infinite?
    2 * (1 - t_cdf(t.abs, gl))
  end

  # ── F de Fisher ──────────────────────────────────────────────────────────────
  def f_cdf(f, gl1, gl2)
    return 0.0 if f <= 0
    return 1.0 if f.infinite?
    f = f.to_f
    ibeta(gl1 * f / (gl1 * f + gl2), gl1 / 2.0, gl2 / 2.0)
  end

  def f_inv(p, gl1, gl2)
    raise ArgumentError, 'p debe estar entre 0 y 1' unless p > 0 && p < 1
    hi = 1.0
    hi *= 2 while f_cdf(hi, gl1, gl2) < p
    biseccion(p, 0.0, hi) { |f| f_cdf(f, gl1, gl2) }
  end

  # Busca x tal que cdf(x) = p, con cdf creciente en [lo, hi]
  def biseccion(p, lo, hi)
    200.times do
      mid = (lo + hi) / 2
      yield(mid) < p ? lo = mid : hi = mid
      break if hi - lo < 1e-12
    end
    (lo + hi) / 2
  end

  # ── Álgebra lineal ───────────────────────────────────────────────────────────
  def transpuesta(m)
    m.first.each_index.map { |j| m.map { |fila| fila[j] } }
  end

  def multiplicar(a, b)
    bt = transpuesta(b)
    a.map { |fila| bt.map { |col| fila.zip(col).sum { |x, y| x * y } } }
  end

  # Inversa por Gauss-Jordan con pivoteo parcial
  def invertir(m)
    n = m.size
    escala = m.flatten.map(&:abs).max
    a = m.each_with_index.map { |fila, i| fila.map(&:to_f) + Array.new(n) { |j| i == j ? 1.0 : 0.0 } }
    n.times do |col|
      piv = (col...n).max_by { |r| a[r][col].abs }
      raise 'Las variables X son colineales (una se puede obtener de las otras); no hay solución única' if a[piv][col].abs < 1e-10 * escala
      a[col], a[piv] = a[piv], a[col]
      pv = a[col][col]
      a[col] = a[col].map { |v| v / pv }
      n.times do |r|
        next if r == col
        f = a[r][col]
        next if f.zero?
        a[r] = a[r].each_with_index.map { |v, j| v - f * a[col][j] }
      end
    end
    a.map { |fila| fila[n..] }
  end
end
