require 'sinatra'
require "sinatra/reloader" if development?
require 'json'

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

# get '/tstudent' do
#   erb :tstudent
# end

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
 