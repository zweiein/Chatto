import AVFoundation
import MediaPlayer

typealias writeDataFunc_t = (_ data : Data)  -> Void
    
class StreamRecord {

    init(inRate fInRate: Float, outRate fOutRate: Float, writeDataFunc: @escaping writeDataFunc_t) {
        m_reSampler = ReSampler(inRate: fInRate, outRate: fOutRate)
        m_writeDataFunc = writeDataFunc
    }

    var isRecording: Bool {
        get {
            return m_bRecording
        }
    }

    @available(iOS 10.0, *)
    func start() -> Bool {
        var bOK = false
        m_serialQueue.sync {
            if !m_bRecording  {
                let audioSession = AVAudioSession.sharedInstance()
                do{
                    //try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .allowBluetooth)
//                    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord, with:AVAudioSession.CategoryOptions.allowBluetooth)

                    // crash on iPad
                    //try! audioSession.setCategory(AVAudioSessionCategoryRecord, with:AVAudioSessionCategoryOptions.allowBluetooth)
                    //try audioSession.setPreferredSampleRate(44100.0)÷
                    try audioSession.setActive(true)
                    
                    print("setPreferredSampleRate : \(audioSession.sampleRate)")
                    
                    audioSession.requestRecordPermission({ (allowd: Bool) -> Void in
                        self.m_reSampler.reset()
                        self.m_bRecording = self.startStreamRecording()
                        bOK = self.m_bRecording
                    })
                } catch {
                    
                    print("audioSession.setActive(true): \(error)")
                }
            }
        }

        return bOK
    }

    func stop() {
        // using sync area to avoid race condition of stop recording from
        // 1) click and 2) remote disconnect
        m_serialQueue.sync {
            if m_bRecording {
                audioEngine.stop()
                audioEngine.mainMixerNode.removeTap(onBus: 0)
                m_bRecording = false
                _ = setDeviceVolume(volume: m_fOldVolume)

                let audioSession = AVAudioSession.sharedInstance()
                do{
                    try audioSession.setActive(false)
                } catch {
                    print("audioSession.setActive(false): \(error)")
                }
            }
        }
    }

    // reference https://stackoverflow.com/questions/44184169/swift-3-avaudioengine-set-microphone-input-format
    private func startStreamRecording() -> Bool {
        var bOK = false
        let inputNode = audioEngine.inputNode
        let bus = 0

        /*
             reference: https://stackoverflow.com/questions/40821754/i-want-to-change-the-sample-rate-from-my-input-node-from-44100-to-8000
             When installing taps, you are not allowed to change the format of the engine's inputNode.
             If you connect the engine's mainMixerNode and installTap on that, you can change the format:
         */

        // attach the new node to the audio engine
        let mixerNode = AVAudioMixerNode()
        audioEngine.attach(mixerNode)

        let inputFormat = inputNode.inputFormat(forBus: bus)
        // bug? only 11025 22050 44100 samplRate record non zero waveform
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100.0, channels: 1, interleaved: true)

        // connect the new node to the output node
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: outputFormat)
        // connect input to the new node, using the input's format
        audioEngine.connect(inputNode, to: mixerNode, format: inputFormat)
        // according to document, valid value range: 0.5~2.0
        mixerNode.rate = 0.5
        mixerNode.volume = 0
        
//        let mainMixer = audioEngine.mainMixerNode
        // tap on the new node, make 150ms 16000 samples = 4800, need 13230 sampels from 44100 sampling rate
        mixerNode.installTap(onBus: 0, bufferSize: 13230, format: outputFormat, block:
//        mixerNode.installTap(onBus: 0, bufferSize: 4800, format: tapFormat)
            {(buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in

            let blockdata = buffer.toSampleData(reSampler: self.m_reSampler)
                
//            print("_._._._._._._._._._._._._._._._._._._._._._._")
//            print(blockdata[0])
//                print(blockdata[1])
//            print("frameLength: \(buffer.frameLength), frameCapacity:\(buffer.frameCapacity)")
//            print("_._._._._._._._._._._._._._._._._._._._._._._")
                
            // send recorded audio to server by websocket
            self.m_writeDataFunc(blockdata)

            //buffer.show_data()
//            _ = self.append_wav_log(pcmBuffer: buffer)

        })

        audioEngine.prepare()
        do {
            try audioEngine.start()
            m_fOldVolume = setDeviceVolume(volume: 0)
            bOK = true
        } catch {
            assertionFailure("AVAudioEngine::start error: \(error)")
        }

        return bOK
    }

    func append_wav_log(pcmBuffer buffer: AVAudioPCMBuffer) -> Bool {
        var bSucc = false

        if nil==m_pcmBuffer {
            m_pcmBuffer = buffer
        } else if let pcmBuffer = m_pcmBuffer {
            let frameLength = pcmBuffer.frameLength + buffer.frameLength
            let outBuffer0 = AVAudioPCMBuffer(pcmFormat: pcmBuffer.format, frameCapacity: frameLength)

            if let outBuffer = outBuffer0 {
                let audioStride = pcmBuffer.stride
                for channelIdx in 0..<pcmBuffer.format.channelCount {
                    let outChannelData = outBuffer.int16ChannelData?.advanced(by: Int(channelIdx)).pointee
                    let origChannelData = pcmBuffer.int16ChannelData?.advanced(by: Int(channelIdx)).pointee
                    let newChannelData = buffer.int16ChannelData?.advanced(by: Int(channelIdx)).pointee
                    
                    for i in stride(from: 0, to: pcmBuffer.frameLength-1, by: 1) {
                        memcpy(origChannelData?.advanced(by: Int(i) * audioStride), outChannelData?.advanced(by: Int(i) * audioStride), MemoryLayout<sample_t>.size)
                    }

                    for i in stride(from: 0, to: buffer.frameLength-1, by: 1) {
                        memcpy(newChannelData?.advanced(by: Int(i) * audioStride), outChannelData?.advanced(by: Int(i+pcmBuffer.frameLength) * audioStride), MemoryLayout<sample_t>.size)
                    }

                    m_pcmBuffer = outBuffer
                    bSucc = true
                }
            }
        }

        return bSucc
    }
    
    // TODO: recordFile.write() always crashed due to unknown ASSERTION FAILURE
    func append_wav_log0(pcmBuffer buffer: AVAudioPCMBuffer) -> Bool {
        var bSucc = false
        // create file according to buffer format, tapFormat crash?
        if nil == self.m_recordFile {
            //let tapFormat = mixerNode.outputFormat(forBus: 0)
            let _mixerOutputFileURL = URL(string: self.compose_record_filename(uuid: ""))
            do {
                self.m_recordFile = try AVAudioFile(forWriting: _mixerOutputFileURL!, settings: buffer.format.settings)
                print("save log to \(_mixerOutputFileURL!)")
            } catch let error as NSError {
                self.m_recordFile = nil
                print("mixerOutputFile is nil, \(error.localizedDescription)")
            }
        }
        if let recordFile = self.m_recordFile {
            do {
                print("writing buffer data to file, \(buffer.frameLength)")
                try recordFile.write(from: buffer)
//                if let buffer1 = buffer.DataToAudioBuffer(data: blockdata) {
//                    try outputFile.write(from: buffer1)
//                }
                bSucc = true
            } catch let error as NSError {
                print("error writing buffer data to file, \(error.localizedDescription)")
            } catch _ {
                fatalError()
            }
        }
        return bSucc
    }
    
    func compose_record_filename(uuid: String) -> String {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let dfString = df.string(from: date)
        var strRecordingName: String
        
        //let pathArray = [dirPath, dfString, recordingName]
        //let filePath = URL(string: pathArray.joined(separator: "/"))
        
        if uuid.isEmpty {
            strRecordingName = "\(dirPath)/\(dfString).wav"
        } else {
            strRecordingName = "\(dirPath)/\(dfString)-\(uuid).wav"
        }
        
        return strRecordingName
    }

    func getDeviceVolume() -> Float {
        let fVolume = AVAudioSession.sharedInstance().outputVolume
        
        return fVolume
    }

    // NOTE: MPVolumeView control only set volume on device,
    // not working on simulator, nor get volume value from control
    // reference https://stackoverflow.com/questions/10286744/how-to-change-device-volume-on-ios-not-music-volume
    func setDeviceVolume(volume fVolume: Float) -> Float {
        var fOldVolume : Float = 0
        let volumeView = MPVolumeView()
        for view in volumeView.subviews {
            if (NSStringFromClass(view.classForCoder) == "MPVolumeSlider") {
                let slider = view as! UISlider

                // always got 0.0 from control, work around
                //fOldVolume = slider.value
                fOldVolume = getDeviceVolume()

                slider.setValue(fVolume, animated: false)

                //print("old volume \(fOldVolume), new volume: \(fVolume)")
                break
            }
        }

        return fOldVolume
    }

//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .Default, handler: nil))
//        self.presentViewController(alert, animated: true, completion: nil)
//    }

    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }

    @available(iOS 10.0, *)
    func play(){
        if let pcmBuffer = m_pcmBuffer {
            m_serialQueue.sync {
                let audioSession = AVAudioSession.sharedInstance()
                do{
                    //try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
                    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .allowBluetooth)
//                    try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.allowBluetooth)
                    try audioSession.setActive(true)
                    
                } catch {
                    print("audioSession.setActive(true): \(error)")
                }
            }
            
            playAudioBuffer(pcmBuffer)
            
            m_serialQueue.sync {
                let audioSession = AVAudioSession.sharedInstance()
                do{
                    try audioSession.setActive(false)
                } catch {
                    print("audioSession.setActive(false): \(error)")
                }
            }
        }
    }
    
    func playAudioBuffer(_ pcmBuffer :AVAudioPCMBuffer){
        let audioPlayerNode = AVAudioPlayerNode()
        
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        audioEngine.attach(audioPlayerNode)
        
//        let changeAudioUnitTime = AVAudioUnitTimePitch()
//        audioEngine.attach(changeAudioUnitTime)
//        changeAudioUnitTime.rate = 1
//        audioEngine.connect(audioPlayerNode, to: changeAudioUnitTime, format: nil)
//        audioEngine.connect(changeAudioUnitTime, to: audioEngine.outputNode, format: nil)
//        audioPlayerNode.scheduleBuffer(pcmBuffer, at: nil, completionHandler: nil)

        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(audioPlayerNode, to: mixer, format: pcmBuffer.format)

        audioPlayerNode.scheduleBuffer(pcmBuffer, at: nil){
            print("stopping")
            // delay because otherwise we can get exclusive access issues
            self.delay(0.1) {
                if self.audioEngine.isRunning {
                    print("engine was running, really stopping")
                    self.audioEngine.stop()
                }
            }
        }
        
        do {
            try audioEngine.start()
        }catch {
//            showAlert("AVAudioEngine::start error", message: String(error))
            print("AVAudioEngine::start error")
        }
        audioPlayerNode.play()
    }

    private let audioEngine = AVAudioEngine()
    private let m_serialQueue = DispatchQueue(label: "RecordLock")
    private var m_reSampler: ReSampler
    private var m_writeDataFunc: writeDataFunc_t
    private var m_recordFile : AVAudioFile?
    private var m_bRecording: Bool = false
    private var m_fOldVolume: Float = 0
    
    private var m_pcmBuffer : AVAudioPCMBuffer? = nil
}
