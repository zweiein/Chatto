
import AVFoundation
typealias sample_t = Int16

extension AVAudioPCMBuffer {
    // reference https://stackoverflow.com/questions/28048568/convert-avaudiopcmbuffer-to-nsdata-and-back
    func toSampleData(reSampler: ReSampler) -> Data {
        //var ch0Data = Data(bytes: pcmBuffer.int16ChannelData![0], count:Int(pcmBuffer.frameCapacity * pcmBuffer.format.streamDescription.pointee.mBytesPerFrame))
        let pcmBuffer = self
        let psIn = pcmBuffer.toSampleArray()
        let psOut = reSampler.convert(psIn: psIn)
        let ch0Data = Data(bytes: psOut, count:psOut.count*MemoryLayout<sample_t>.size)
        
        return ch0Data
    }

    // https://stackoverflow.com/questions/42722865/accessing-float-samples-of-avaudiopcmbuffer-for-processing
    func toSampleArray() -> [sample_t] {
        let audioBuffer = self
        let bytesPerFrame = audioBuffer.format.streamDescription.pointee.mBytesPerFrame
        let numBytes = Int(bytesPerFrame * audioBuffer.frameLength)
        
        let arraySize = Int(numBytes/MemoryLayout<sample_t>.size)
        let audioSampleArray = Array(UnsafeBufferPointer(start: audioBuffer.int16ChannelData![0], count:arraySize))

        return audioSampleArray
    }

    // reference https://stackoverflow.com/questions/28048568/convert-avaudiopcmbuffer-to-nsdata-and-back
    func sampleArraytoData(sampleArray: [sample_t]) -> Data {
        return Data(bytes: sampleArray, count:sampleArray.count*MemoryLayout<sample_t>.size)
    }
    
    func show_data() {
        let buffer = self
        let bytes = Int(buffer.frameCapacity * buffer.format.streamDescription.pointee.mBytesPerFrame)
        print ("streaming record \(buffer.format): \(bytes) bytes")
        
        if let channelData = buffer.int16ChannelData {
            let values = UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength))
            let arr = Array(values)
//            print(arr)
            
            var num_nonzero = 0
            for i in 0..<arr.count {
                if arr[i] != 0 {
                    num_nonzero += 1
                }
            }
            print("total \(num_nonzero) non zero value recorded")
            
        } else {
            print("buffer.int16ChannelData is nil")
        }
    }

    // https://stackoverflow.com/questions/42163620/how-to-convert-avaudiopcmbuffer-to-uint8-array-and-uint8-array-into-avaudiopcmbu
    // not yet verified
    func SampleArrayToAudioBuffer(_ buf: [sample_t]) -> AVAudioPCMBuffer? {
        
        let fmt = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000.0, channels: 1, interleaved: true)
        let frameLength = UInt32(buf.count) / fmt!.streamDescription.pointee.mBytesPerFrame
        
        print("OXOX1 sampleArray: \(buf.count), frameLength: \(frameLength)")

        if let audioBuffer = AVAudioPCMBuffer(pcmFormat: fmt!, frameCapacity: frameLength) {
            audioBuffer.frameLength = frameLength

            print("OXOX2 frameLength: \(frameLength)")

            let dstLeft = audioBuffer.int16ChannelData![0]
            // for stereo
            // let dstRight = audioBuffer.int16ChannelData![1]
            
            buf.withUnsafeBufferPointer {
                let src = UnsafeRawPointer($0.baseAddress!).bindMemory(to: sample_t.self, capacity: Int(frameLength))
                dstLeft.initialize(from: src, count: Int(frameLength))
            }
            return audioBuffer
        }
        return nil
    }
    
    // not yet verified
    func DataToSampleArray(data: Data) -> [sample_t] {
        let arraySize = Int(data.count/MemoryLayout<sample_t>.size)
        let audioSampleArray = data.withUnsafeBytes {
            UnsafeBufferPointer<Int16>(start: $0, count: arraySize).map(Int16.init(littleEndian:))
        }
        return audioSampleArray
    }

    // not yet verified
    func DataToAudioBuffer(data: Data) -> AVAudioPCMBuffer? {
//        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true)
//
//        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(data.count)) else {
//            return nil
//        }
//
//        audioBuffer.frameLength = (audioBuffer.frameCapacity)
//        let sampleArray = self.DataToSampleArray(data: data)
//        SampleArrayToAudioBuffer
//        for i in 0..<data.count {
//            audioBuffer.int16ChannelData?.pointee[i] = sampleArray[i]
//        }

        let sampleArray = self.DataToSampleArray(data: data)
        let audioBuffer = self.SampleArrayToAudioBuffer(sampleArray)

        return audioBuffer
    }
}
