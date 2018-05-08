package utils;


// FROM: http://lab.polygonal.de/?p=162
/*
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
/**
 * Implementation of the Park Miller (1988) "minimal standard" linear 
 * congruential pseudo-random number generator.
 * 
 * For a full explanation visit: http://www.firstpr.com.au/dsp/rand31/
 * 
 * The generator uses a modulus constant (m) of 2^31 - 1 which is a
 * Mersenne Prime number and a full-period-multiplier of 16807.
 * Output is a 31 bit unsigned integer. The range of values output is
 * 1 to 2,147,483,646 (2^31-1) and the seed must be in this range too.
 * 
 * David G. Carta's optimisation which needs only 32 bit integer math,
 * and no division is actually *slower* in flash (both AS2 & AS3) so
 * it's better to use the double-precision floating point version.
 * 
 * @author Michael Baczynski, www.polygonal.de
 */
class PMPRNG
{
    /**
     * set seed with a 31 bit unsigned integer
     * between 1 and 0X7FFFFFFE inclusive. don't use 0!
     */
    public var seed : Int;
    
    public function new(_seed : Int = 0)
    {
        if (_seed < 1)
        {
            _seed = 1;
        }
        seed = _seed % 2147483646;
    }
    
    /**
				 * generate a new PM_PRNG, seeded
				 * using the given RNG or Math.random if null.
				 */
    public static function createGen(rand : PMPRNG) : PMPRNG
    {
        var randNum : Float = (rand != null) ? rand.nextDouble() : Math.random();
        return new PMPRNG(Math.floor(randNum * (2147483646 - 2)) + 1);
    }
    
    /**
     * provides the next pseudorandom number
     * as an unsigned integer (31 bits)
     */
    public function nextInt() : Int
    {
        return gen();
    }
    
    /**
     * provides the next pseudorandom number
     * as a float between nearly 0 and nearly 1.0.
     */
    public function nextDouble() : Float
    {
        return (gen() / 2147483647);
    }
    
    /**
     * provides the next pseudorandom number
     * as an unsigned integer (31 bits) betweeen
     * a given range.
     */
    public function nextIntRange(min : Float, max : Float) : Int
    {
        min -= .4999;
        max += .4999;
        return Math.round(min + ((max - min) * nextDouble()));
    }
    
    /**
     * provides the next pseudorandom number
     * as a float between a given range.
     */
    public function nextDoubleRange(min : Float, max : Float) : Float
    {
        return min + ((max - min) * nextDouble());
    }
    
    /**
     * generator:
     * new-value = (old-value * 16807) mod (2^31 - 1)
     */
    private function gen() : Int
    //integer version 1, for max int 2^46 - 1 or larger.
    {
        
        return seed = (seed * 16807) % 2147483647;
    }
}
