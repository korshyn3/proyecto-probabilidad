require 'sinatra'
require "sinatra/reloader" if development?
require 'json'
require_relative 'lib/estadistica'

also_reload File.join(__dir__, 'lib', '*.rb') if development?

set :port, ENV.fetch('PORT', 4567)
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'

get '/' do
  erb :home
end

get '/varianza' do
  erb :varianza
end

get '/valor_esperado' do
  erb :valor_esperado
end

get '/normal' do
  erb :normal
end

get '/tstudent' do
  erb :tstudent
end

get '/tamano_muestra' do
  erb :tamano_muestra
end

get '/anova' do
  erb :anova
end

get '/regresion' do
  erb :regresion
end

get '/regresion_multiple' do
  erb :regresion_multiple
end

get '/problemas' do
  erb :problemas
end

get '/acerca' do
  erb :acerca
end

def parse_num(str)
  s = str.strip
  if s.include?('/')
    parts = s.split('/')
    raise ArgumentError unless parts.length == 2
    Float(parts[0].strip) / Float(parts[1].strip)
  else
    Float(s)
  end
end

post '/calcular_esperado' do
  content_type :json
  begin
    xs_raw = params[:xs] || ''
    ps_raw = params[:ps] || ''

    xs = xs_raw.split(',').map { |x| parse_num(x) }
    ps = ps_raw.split(',').map { |x| parse_num(x) }

    raise 'Ingresa al menos 2 pares (x, P(x))' if xs.length < 2
    raise 'La cantidad de valores x y P(x) debe ser igual' if xs.length != ps.length
    raise 'Todas las probabilidades deben ser >= 0' if ps.any? { |p| p < 0 }
    raise 'La suma de P(x) debe ser 1 (tolerancia ±0.001)' if (ps.sum - 1.0).abs > 0.001

    esperado  = xs.zip(ps).sum { |x, p| x * p }
    esperado2 = xs.zip(ps).sum { |x, p| x**2 * p }
    varianza  = esperado2 - esperado**2
    desv      = Math.sqrt([varianza, 0.0].max)

    pasos = xs.zip(ps).map { |x, p|
      { x: x, p: p.round(6), xp: (x * p).round(6), x2p: (x**2 * p).round(6) }
    }

    {
      status: 'ok',
      n: xs.length,
      esperado:  esperado.round(6),
      esperado2: esperado2.round(6),
      varianza:  varianza.round(6),
      desv:      desv.round(6),
      pasos:     pasos
    }.to_json
  rescue ArgumentError, ZeroDivisionError
    { status: 'error', mensaje: 'Ingresa números o fracciones válidas (ej: 1/6), separados por comas' }.to_json
  rescue RuntimeError => e
    { status: 'error', mensaje: e.message }.to_json
  end
end

post '/calcular' do
  content_type :json

  begin
    datos_raw = params[:datos] || ''
    datos = datos_raw.split(',').map { |x| Float(x.strip) }

    raise 'Ingresa al menos 2 números' if datos.length < 2

    n = datos.length
    media = datos.sum / n.to_f
    varianza_poblacional = datos.map { |x| (x - media)**2 }.sum / n.to_f
    varianza_muestral = datos.map { |x| (x - media)**2 }.sum / (n - 1).to_f
    desv_poblacional = Math.sqrt(varianza_poblacional)
    desv_muestral = Math.sqrt(varianza_muestral)

    {
      status: 'ok',
      n: n,
      datos: datos,
      media: media.round(6),
      varianza_poblacional: varianza_poblacional.round(6),
      varianza_muestral: varianza_muestral.round(6),
      desv_poblacional: desv_poblacional.round(6),
      desv_muestral: desv_muestral.round(6),
      pasos: datos.map { |x| {
        valor: x,
        cuadrado: ((x - media)**2).round(6)
      }}
    }.to_json

  rescue ArgumentError
    { status: 'error', mensaje: 'Solo ingresa números separados por comas' }.to_json
  rescue RuntimeError => e
    { status: 'error', mensaje: e.message }.to_json
  end
end

# ── Helpers para las calculadoras de inferencia y regresión ─────────────────

# Lista de números separados por comas, espacios, punto y coma o saltos de línea
def parse_lista(str)
  str.to_s.split(/[\s,;]+/).reject(&:empty?).map { |x| parse_num(x) }
end

# Redondea para JSON; Infinity/NaN no existen en JSON, se mandan como null
def num(x, dec = 6)
  x.is_a?(Float) && !x.finite? ? nil : x.round(dec)
end

def leer_alfa
  alfa = Float(params[:alfa].to_s.strip.empty? ? '0.05' : params[:alfa])
  raise 'α debe estar entre 0 y 1 (ej: 0.05)' unless alfa > 0 && alfa < 1
  alfa
end

def responder
  content_type :json
  yield.merge(status: 'ok').to_json
rescue ArgumentError, TypeError, JSON::ParserError
  { status: 'error', mensaje: 'Revisa los datos: solo se aceptan números (se permiten decimales y fracciones como 1/2)' }.to_json
rescue RuntimeError => e
  { status: 'error', mensaje: e.message }.to_json
end

# ── Tamaño de muestra ────────────────────────────────────────────────────────
post '/calcular_tamano' do
  responder do
    tipo      = params[:tipo] == 'proporcion' ? 'proporcion' : 'media'
    buscar    = params[:buscar] == 'error' ? 'error' : 'n'
    confianza = Float(params[:confianza])
    raise 'El nivel de confianza debe estar entre 0 y 100 (ej: 95)' unless confianza > 0 && confianza < 100
    z = Estadistica.normal_inv(1 - (1 - confianza / 100) / 2)

    # Lo que va dentro de la fórmula: σ² para medias, p(1 − p) para proporciones
    if tipo == 'media'
      sigma = Float(params[:sigma])
      raise 'La desviación estándar σ debe ser mayor que 0' unless sigma > 0
      varianza = sigma**2
    else
      p = params[:p].to_s.strip.empty? ? 0.5 : parse_num(params[:p])
      raise 'La proporción p debe estar entre 0 y 1' unless p > 0 && p < 1
      varianza = p * (1 - p)
    end

    poblacion = params[:poblacion].to_s.strip
    pob = poblacion.empty? ? nil : Integer(poblacion)
    raise 'El tamaño de la población N debe ser un entero mayor que 0' if pob && pob <= 0

    if buscar == 'n'
      error = Float(params[:error])
      raise 'El error máximo E debe ser mayor que 0' unless error > 0
      raise 'Para proporciones, E debe estar entre 0 y 1 (ej: 0.05 = 5%)' if tipo == 'proporcion' && error >= 1
      n0 = z**2 * varianza / error**2
      n_final = pob ? n0 / (1 + (n0 - 1) / pob) : n0
      { tipo: tipo, buscar: buscar, z: num(z), poblacion: pob,
        n0: num(n0), n_exacto: num(n_final), n: n_final.round(9).ceil }
    else
      n = Integer(params[:n])
      raise 'El tamaño de muestra n debe ser un entero mayor que 1' unless n > 1
      raise 'La muestra n no puede ser mayor que la población N' if pob && n > pob
      e0 = z * Math.sqrt(varianza / n)
      # Factor de corrección por población finita: √((N − n) / (N − 1))
      fpc = pob ? Math.sqrt((pob - n).to_f / (pob - 1)) : 1.0
      { tipo: tipo, buscar: buscar, z: num(z), poblacion: pob, n: n,
        e0: num(e0), fpc: num(fpc), error: num(e0 * fpc) }
    end
  end
end

# ── ANOVA de un factor ───────────────────────────────────────────────────────
post '/calcular_anova' do
  responder do
    alfa   = leer_alfa
    grupos = JSON.parse(params[:grupos] || '[]').map { |g| parse_lista(g) }.reject(&:empty?)
    raise 'Ingresa al menos 2 grupos con datos' if grupos.length < 2
    raise 'Cada grupo necesita al menos 2 datos' if grupos.any? { |g| g.length < 2 }

    k = grupos.length
    total = grupos.flatten
    n_total = total.length
    media_global = total.sum / n_total

    stats = grupos.map do |g|
      media = g.sum / g.length
      sc = g.sum { |x| (x - media)**2 }
      { n: g.length, suma: g.sum, media: media, varianza: sc / (g.length - 1), sc: sc, datos: g }
    end

    scb = stats.sum { |s| s[:n] * (s[:media] - media_global)**2 }
    scw = stats.sum { |s| s[:sc] }
    gl_b = k - 1
    gl_w = n_total - k
    cmb = scb / gl_b
    cmw = scw / gl_w
    raise 'No hay variación dentro de los grupos (cada grupo tiene todos sus datos iguales); F no se puede calcular' if cmw.zero?

    f = cmb / cmw
    f_crit = Estadistica.f_inv(1 - alfa, gl_b, gl_w)

    {
      alfa: alfa, k: k, n_total: n_total, media_global: num(media_global),
      grupos: stats.map { |s| { n: s[:n], suma: num(s[:suma]), media: num(s[:media]), varianza: num(s[:varianza]), contrib: num(s[:n] * (s[:media] - media_global)**2), datos: s[:datos] } },
      scb: num(scb), scw: num(scw), sct: num(scb + scw),
      gl_b: gl_b, gl_w: gl_w, gl_t: n_total - 1,
      cmb: num(cmb), cmw: num(cmw),
      f: num(f), p_valor: num(1 - Estadistica.f_cdf(f, gl_b, gl_w), 8), f_crit: num(f_crit),
      rechaza: f > f_crit
    }
  end
end

# ── Regresión lineal simple ──────────────────────────────────────────────────
post '/calcular_regresion' do
  responder do
    alfa = leer_alfa
    xs = parse_lista(params[:xs])
    ys = parse_lista(params[:ys])
    raise 'La cantidad de valores de x y de y debe ser igual' if xs.length != ys.length
    raise 'Ingresa al menos 3 pares (x, y)' if xs.length < 3

    n = xs.length
    mx = xs.sum / n
    my = ys.sum / n
    sxx = xs.sum { |x| (x - mx)**2 }
    syy = ys.sum { |y| (y - my)**2 }
    sxy = xs.zip(ys).sum { |x, y| (x - mx) * (y - my) }
    raise 'Todos los valores de x son iguales; no se puede ajustar una recta' if sxx.zero?

    b1 = sxy / sxx
    b0 = my - b1 * mx
    pred = xs.map { |x| b0 + b1 * x }
    res = ys.zip(pred).map { |y, yh| y - yh }
    sce = res.sum { |e| e**2 }
    scr = syy - sce
    r2 = syy.zero? ? 1.0 : scr / syy
    r = syy.zero? ? 0.0 : sxy / Math.sqrt(sxx * syy)

    gl = n - 2
    se = Math.sqrt(sce / gl)
    se_b1 = se / Math.sqrt(sxx)
    se_b0 = se * Math.sqrt(1.0 / n + mx**2 / sxx)
    t_b1 = se_b1.zero? ? Float::INFINITY * (b1 <=> 0) : b1 / se_b1
    t_crit = Estadistica.t_inv(1 - alfa / 2, gl)

    {
      alfa: alfa, n: n, media_x: num(mx), media_y: num(my),
      sxx: num(sxx), syy: num(syy), sxy: num(sxy),
      b0: num(b0), b1: num(b1), r: num(r), r2: num(r2),
      se: num(se), se_b0: num(se_b0), se_b1: num(se_b1),
      t_b1: num(t_b1), p_b1: num(Estadistica.t_p_dos_colas(t_b1, gl), 8),
      t_crit: num(t_crit), gl: gl,
      ic_b1: [num(b1 - t_crit * se_b1), num(b1 + t_crit * se_b1)],
      rechaza: t_b1.abs > t_crit,
      sce: num(sce), scr: num(scr), sct: num(syy),
      pasos: xs.each_index.map { |i|
        { x: xs[i], y: ys[i], xy: num(xs[i] * ys[i]), x2: num(xs[i]**2), y_hat: num(pred[i]), residuo: num(res[i]) }
      }
    }
  end
end

# ── Regresión lineal múltiple ────────────────────────────────────────────────
post '/calcular_regresion_multiple' do
  responder do
    alfa = leer_alfa
    ys = parse_lista(params[:ys])
    xs = JSON.parse(params[:xs] || '[]').map { |col| parse_lista(col) }.reject(&:empty?)
    raise 'Ingresa al menos una variable X' if xs.empty?
    raise 'Cada variable X debe tener la misma cantidad de valores que y' if xs.any? { |col| col.length != ys.length }

    n = ys.length
    k = xs.length
    gl_e = n - k - 1
    raise "Con #{k} variable(s) X necesitas al menos #{k + 2} observaciones" if gl_e < 1

    # Matriz de diseño con una columna de 1s para el intercepto
    x = (0...n).map { |i| [1.0] + xs.map { |col| col[i] } }
    xt = Estadistica.transpuesta(x)
    xtx_inv = Estadistica.invertir(Estadistica.multiplicar(xt, x))
    beta = Estadistica.multiplicar(xtx_inv, Estadistica.multiplicar(xt, ys.map { |y| [y] })).map(&:first)

    pred = x.map { |fila| fila.zip(beta).sum { |a, b| a * b } }
    res = ys.zip(pred).map { |y, yh| y - yh }
    my = ys.sum / n
    sct = ys.sum { |y| (y - my)**2 }
    raise 'Todos los valores de y son iguales; no hay variación que explicar' if sct.zero?
    sce = res.sum { |e| e**2 }
    scr = sct - sce

    cme = sce / gl_e
    r2 = scr / sct
    f = cme.zero? ? Float::INFINITY : (scr / k) / cme
    f_crit = Estadistica.f_inv(1 - alfa, k, gl_e)
    t_crit = Estadistica.t_inv(1 - alfa / 2, gl_e)

    coefs = beta.each_with_index.map do |b, j|
      se = Math.sqrt([cme * xtx_inv[j][j], 0.0].max)
      t = se.zero? ? Float::INFINITY * (b <=> 0) : b / se
      {
        nombre: j.zero? ? 'β₀' : "β#{j}", b: num(b), se: num(se), t: num(t),
        p: num(Estadistica.t_p_dos_colas(t, gl_e), 8), significativo: t.abs > t_crit
      }
    end

    {
      alfa: alfa, n: n, k: k, gl_r: k, gl_e: gl_e, gl_t: n - 1,
      coefs: coefs, r2: num(r2), r2_aj: num(1 - (1 - r2) * (n - 1) / gl_e), se: num(Math.sqrt(cme)),
      scr: num(scr), sce: num(sce), sct: num(sct), cmr: num(scr / k), cme: num(cme),
      f: num(f), p_f: num(1 - Estadistica.f_cdf(f, k, gl_e), 8),
      f_crit: num(f_crit), t_crit: num(t_crit), rechaza: f > f_crit,
      pasos: ys.each_index.map { |i|
        { xs: xs.map { |col| col[i] }, y: ys[i], y_hat: num(pred[i]), residuo: num(res[i]) }
      }
    }
  end
end
 