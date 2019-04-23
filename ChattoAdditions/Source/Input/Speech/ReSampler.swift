import Foundation

class ReSampler {

    typealias sample_t = Int16
    typealias size_t = Int

    // do exactly reset() did, but swift no allow to call function before initialed
    init(inRate fInRate: Float, outRate fOutRate: Float){
        m_bFirst = true
        
        m_nInOffset  = 0
        m_nOutOffset = 0
        m_sLastSample = 0
        
        // check if support
        assert(44100.0==fInRate && 16000.0==fOutRate)
        m_fInRate = fInRate
        m_fOutRate = fOutRate
    }

    func reset(){
        m_bFirst = true
        
        m_nInOffset  = 0
        m_nOutOffset = 0
        m_sLastSample = 0
    }
    
    func convert(psIn: [sample_t]) -> [sample_t] {
        assert(44100.0==m_fInRate && 16000.0==m_fOutRate)
        
        // in case of other input/output sampling rate/channel, apply coresponding filter
        var psLPFIn = psIn
        LPF8000On44100(psData: &psLPFIn);
        
        let factor = Double(m_fInRate/m_fOutRate)
        var psOut = [sample_t]()
        
        let nLen = resample(psIn: psLPFIn, psOut: &psOut, factor: factor, last_sample: m_sLastSample, in_offset: m_nInOffset, out_offset: m_nOutOffset)
        m_nInOffset += psIn.count
        m_sLastSample = psLPFIn[psLPFIn.count-1]
        m_nOutOffset += nLen
        
        return psOut
    }

    private func rounding_to_sample(sample dSample: Double) -> sample_t {
        let MAX_SAMPLE: Double = Double(sample_t.max)
        let MIN_SAMPLE: Double = Double(sample_t.min)

        var dResult : Double = dSample > 0 ? (dSample + 0.5):(dSample - 0.5);
        if dResult > MAX_SAMPLE{
            dResult = MAX_SAMPLE;
        }else if dResult < MIN_SAMPLE {
            dResult = MIN_SAMPLE;
        }
        return sample_t(dResult);
    }

    private func LPF8000On44100(psData : inout [sample_t]) {
        let GAIN = 8.187981712e+02

        if m_bFirst {
            for i in 0..<ReSampler.NZEROS { xv[i+1] = 0 }
            for i in 0..<ReSampler.NPOLES { yv[i+1] = 0 }
            m_bFirst = false
        }
        
        for i in 0..<psData.count {
            xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6]; xv[6] = xv[7]; xv[7] = xv[8]
            xv[8] = Double(psData[i]) / GAIN
            yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6]; yv[6] = yv[7]; yv[7] = yv[8]

            yv[8] = (xv[0] + xv[8])
            yv[8] += (8 * (xv[1] + xv[7]))   + (28 * (xv[2] + xv[6]))
            yv[8] += (56 * (xv[3] + xv[5]))  + (70 * xv[4])
            yv[8] += (-0.0018453850 * yv[0]) + (0.0254503167 * yv[1])
            yv[8] += (-0.1603748944 * yv[2]) + (0.6009034250 * yv[3])
            yv[8] += (-1.5001957966 * yv[4]) + (2.5309101694 * yv[5])
            yv[8] += (-2.9903049132 * yv[6]) + (2.1828037173 * yv[7])

            psData[i] = rounding_to_sample(sample: yv[8])
        }
    }

    // reference https://forum.juce.com/t/urgent-record-a-file-in-16khz-or-downsampling-a-file-to-16khz/12730/11
    private func resample(psIn: [sample_t], psOut: inout [sample_t], factor: Double, last_sample: sample_t,  in_offset: size_t, out_offset: size_t) -> size_t {
        psOut.removeAll()
        while true {
            let index: Double = (Double(psOut.count)+Double(out_offset)) * factor

            // boundary case: interploation using the last sample of previous batch the first sample of current batch
            if index < Double(in_offset) {
                assert(0==psOut.count, "boundary using less than last sample")
                let mu: Double = index - Double(in_offset + 1) // remainder
                psOut.append(rounding_to_sample(sample: Double(last_sample) * (1 - mu) + Double(psIn[0]) * mu))
                continue
            }

            let x1: size_t = size_t(index) - in_offset; // floor
            let x2: size_t = x1 + 1; // ceil
            
            // interpolation need the next sample
            if x2 >= psIn.count {
                break
            }
            
            let mu: Double = index - Double(in_offset) - Double(x1) // remainder
            psOut.append(rounding_to_sample(sample: Double(psIn[x1]) * (1 - mu) + Double(psIn[x2]) * mu))
        }

        return psOut.count
    }

    static private let NZEROS = 8
    static private let NPOLES = 8
    
    private var m_bFirst : Bool
    private var m_sLastSample : sample_t
    private var m_fInRate, m_fOutRate: Float
    
    private var xv   = [Double](repeating: 0.0, count: NZEROS+1)
    private var yv   = [Double](repeating: 0.0, count: NPOLES+1)
    
    private var m_nInOffset, m_nOutOffset : size_t
}
