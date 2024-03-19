#!/usr/bin/env lua

-- this is one of my first Lua programs!
-- I am about to implement the mandelbrot set

-- obtain the terminal dimensions, WIDTH and HEIGHT
termdim_handle = io.popen("stty size", "r")
termdims = termdim_handle:read()
h, w = string.match(termdims, "(%d+)%s+(%d+)")
h, w = tonumber(h)-1 or 80, tonumber(w) or 120
-- an estimate of the terminal character aspect ratio (height vs width)
ratio = 16/7
rows = math.min(w / ratio, h)
cols = math.min(h * ratio, w)

screen = {
  max = { w = w, h = h }, w = cols, h = rows,
  x = { min = -1.8, max = 0.6 },
  y = { min = -1.4, max = 1.4 },
  }

screen.x.range = screen.x.max - screen.x.min
screen.y.range = screen.y.max - screen.y.min

-- idea!! what if the entire display started off at iters = 0++ and then the
-- colors changed as iters++ and various values escaped?
--
-- loop through each display pixel
-- map display to a set of coordinates based on the current field of view
-- for each coordinate, determine how many loop iterations it takes to exit the
-- mandelbrot set
-- draw that pixel with a corresponding value
--
-- need to figure out a way to draw on the terminal to display this

function complex_add(a, b)
  return { r = (a.r + b.r), i = (a.i + b.i) }
end

function complex_mul(a, b)
  --[[
  a = ar + ai
  b = br + bi

  a * b = (ar+ai)(br+bi) = arbr + arbi + aibr - aibi
  cr = arbr - aibi
  ci = arbi + aibr
  ]]

  return { r = (a.r*b.r - a.i*b.i), i = (a.r*b.i + a.i*b.r) }
end

function complex_sqr(a)
  return complex_mul(a, a)
end

function complex_mag_sqr(a)
  return a.r^2 + a.i^2
end

function mandel(screen, x, y, M)
  local c = { r = x, i = y }
  local z = c

  for i = 0, M do
    if complex_mag_sqr(z) > 4 then
      return i
    end

    z = complex_add( complex_sqr(z), c )
  end

  return M
end

function coords(screen, r, c)
  local x = (c + 0.5) * (screen.x.range / screen.w) + screen.x.min
  local y = (r + 0.5) * (screen.y.range / screen.h) + screen.y.min

  return x, y
end

function prec(val, p)
  return val - val%(10^-p)
end

function round(x)
  local f = math.floor(x)
  if (x == f) or (x%2.0 == 0.5) then
    return f
  else
    return math.floor(x + 0.5)
  end
end

function center(screen, text)
  padding = screen.max.w - #text
  if padding < 0 then
    -- truncate printed text
    io.write( string.sub(text, 1, screen.w) )
  else
    io.write( string.format("%s%s", string.rep(" ", padding // 2), text) )
  end
end

-- START OF MANDELBROT SCRIPT

N = 26

for r = 0, screen.h-1 do
  local line = {}
  for c = 0, screen.w-1 do
    x, y = coords(screen, r, c)

    iters = mandel(screen, x, y, N)
    char = iters >= N and ' ' or string.char(string.byte(' ') + round(iters * 26 / N))
    --char = string.char(string.byte(' ') - 1 + round(iters * 26 / N))
    line[#line + 1] = char
    
    --print( prec(x, 3), prec(y, 3) )
  end
  print(center(screen, table.concat(line)))
end

io.flush()
