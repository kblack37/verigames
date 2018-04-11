package cgs.utils.gen;

import fg.system.FGSystem;

class FGRandomIntegerGenerator
{
    private var m_min : Int;
    private var m_max : Int;
    private var m_range : Int;
    private var _randomGenerator:PMPRNG = new PMPRNG();
    
    public function new(min : Int, max : Int, randomGenerator:PMPRNG = null)
    {
        m_min = min;
        m_max = max;
        if (randomGenerator != null)
        {
            _randomGenerator = randomGenerator;
        }
    }
    
    public function nextInt() : Int
    {
        return _randomGenerator.nextIntRange(m_min, m_max);
    }
}
