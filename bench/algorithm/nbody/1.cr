# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# Optimized for Ruby by Jesse Millikan
# From version ported by Michael Neumann from the C gcc version,
# which was written by Christoph Bauer.
# ported from ruby to crystal by hanabi1224

SOLAR_MASS    = 4_f64 * Math::PI**2
DAYS_PER_YEAR = 365.24_f64

class Planet
  property x
  property y
  property z
  property vx
  property vy
  property vz
  property mass

  def initialize(x : Float64, y : Float64, z : Float64, vx : Float64, vy : Float64, vz : Float64, mass : Float64)
    @x, @y, @z = x, y, z
    @vx, @vy, @vz = Float64.new(vx * DAYS_PER_YEAR), Float64.new(vy * DAYS_PER_YEAR), Float64.new(vz * DAYS_PER_YEAR)
    @mass = Float64.new(mass * SOLAR_MASS)
  end

  def move_from_i(bodies, nbodies, dt, i)
    while i < nbodies
      b2 = bodies[i]
      dx = @x - b2.x
      dy = @y - b2.y
      dz = @z - b2.z

      distance_square = dx * dx + dy * dy + dz * dz
      distance = Math.sqrt(distance_square)
      mag = dt / (distance * distance_square)
      b_mass_mag, b2_mass_mag = @mass * mag, b2.mass * mag

      @vx -= dx * b2_mass_mag
      @vy -= dy * b2_mass_mag
      @vz -= dz * b2_mass_mag
      b2.vx += dx * b_mass_mag
      b2.vy += dy * b_mass_mag
      b2.vz += dz * b_mass_mag
      i += 1
    end

    @x += dt * @vx
    @y += dt * @vy
    @z += dt * @vz
  end
end

def energy(bodies)
  e = 0.0
  nbodies = bodies.size

  (0...nbodies).each do |i|
    b = bodies[i]
    e += 0.5 * b.mass * (b.vx * b.vx + b.vy * b.vy + b.vz * b.vz)
    ((i + 1)...nbodies).each do |j|
      b2 = bodies[j]
      dx = b.x - b2.x
      dy = b.y - b2.y
      dz = b.z - b2.z
      distance = Math.sqrt(dx * dx + dy * dy + dz * dz)
      e -= (b.mass * b2.mass) / distance
    end
  end
  e
end

def offset_momentum(bodies)
  px, py, pz = 0.0, 0.0, 0.0

  bodies.each do |b|
    m = b.mass
    px -= b.vx * m
    py -= b.vy * m
    pz -= b.vz * m
  end

  b = bodies[0]
  b.vx = px / SOLAR_MASS
  b.vy = py / SOLAR_MASS
  b.vz = pz / SOLAR_MASS
end

BODIES = [
  # sun
  Planet.new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0),

  # jupiter
  Planet.new(
    4.84143144246472090e+00,
    -1.16032004402742839e+00,
    -1.03622044471123109e-01,
    1.66007664274403694e-03,
    7.69901118419740425e-03,
    -6.90460016972063023e-05,
    9.54791938424326609e-04),

  # saturn
  Planet.new(
    8.34336671824457987e+00,
    4.12479856412430479e+00,
    -4.03523417114321381e-01,
    -2.76742510726862411e-03,
    4.99852801234917238e-03,
    2.30417297573763929e-05,
    2.85885980666130812e-04),

  # uranus
  Planet.new(
    1.28943695621391310e+01,
    -1.51111514016986312e+01,
    -2.23307578892655734e-01,
    2.96460137564761618e-03,
    2.37847173959480950e-03,
    -2.96589568540237556e-05,
    4.36624404335156298e-05),

  # neptune
  Planet.new(
    1.53796971148509165e+01,
    -2.59193146099879641e+01,
    1.79258772950371181e-01,
    2.68067772490389322e-03,
    1.62824170038242295e-03,
    -9.51592254519715870e-05,
    5.15138902046611451e-05),
]

n = ARGV.size > 0 ? ARGV[0].to_i : 1000

offset_momentum(BODIES)

puts "%.9f" % energy(BODIES)

nbodies = BODIES.size
dt = 0.01

n.times do
  i = 0
  while i < nbodies
    b = BODIES[i]
    b.move_from_i(BODIES, nbodies, dt, i + 1)
    i += 1
  end
end

puts "%.9f" % energy(BODIES)
