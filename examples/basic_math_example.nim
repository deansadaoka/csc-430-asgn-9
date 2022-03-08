import std/math

# Basic math.
assert 1 + 2 == 3        # Sum
assert 4 - 1 == 3        # Subtraction
assert 2 * 2 == 4        # Multiplication
assert 4 / 2 == 2.0      # Division
assert 4 div 2 == 2      # Integer Division
assert 2 ^ 3 == 8        # Power
assert 4 mod 2 == 0      # Modulo
assert (2 xor 4) == 6    # XOR
assert (4 shr 2) == 1    # Shift Right
assert PI * 2 == TAU     # PI and TAU
assert sqrt(4.0) == 2.0  # Square Root
assert round(3.5) == 4.0 # Round
assert isPowerOfTwo(16)  # Powers of Two
assert floor(2.9) == 2.0 # Floor
assert ceil(2.9) == 3.0  # Ceil
assert cos(TAU) == 1.0   # Cosine
assert gcd(12, 8) == 4   # Greatest common divisor
assert trunc(1.75) == 1.0     # Truncate
assert floorMod(8, 3) == 2    # Floor Modulo
assert floorDiv(8, 3) == 2    # Floor Division
assert hypot(4.0, 3.0) == 5.0 # Hypotenuse
assert gamma(4.0) == 6.0      # Gamma function
assert radToDeg(TAU) == 360.0 # Radians to Degrees
assert clamp(1.4, 0.0 .. 1.0) == 1.0 # Clamp
assert almostEqual(PI, 3.14159265358979)
assert euclDiv(-13, -3) == 5  # Euclidean Division
assert euclMod(-13, 3) == 2   # Euclidean Modulo