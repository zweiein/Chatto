/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit
import Photos
import Chatto
import AVFoundation
import SwiftWebSocket
import AudioKit

protocol SpeechInputViewProtocol {
    var presentingController: UIViewController? { get }
//    func getTranscription() -> String
}

class SpeechInputView: UIView, SpeechInputViewProtocol, WebSocketASRDelegate {
    fileprivate var uiView: UIView!
    var speechConfigs: SpeechOptions?
    @IBOutlet weak var displayTextLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    public var transcript: String!
    var hasNewSpeechOptions: Bool = false
    var notificationCenter: NotificationCenter = NotificationCenter.default
    
    enum RecordingState: Int { case IDLE=0, WAIT_CONNECTED, RECORDING, WAIT_RECORDING_FINISH }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 10.0, *) {
            self.commonInit()
        } else {
            // Fallback on earlier versions
            print("Please use iOS 10.0 or upper")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if #available(iOS 10.0, *) {
            self.commonInit()
        } else {
            // Fallback on earlier versions
            print("Please use iOS 10.0 or upper")
        }
    }

    weak var presentingController: UIViewController?
    init(presentingController: UIViewController?) {
        super.init(frame: CGRect.zero)
        self.presentingController = presentingController
        if #available(iOS 10.0, *) {
            self.commonInit()
        } else {
            // Fallback on earlier versions
            print("Please use iOS 10.0 or upper")
        }
    }
    
    init(presentingController: UIViewController?, speechParameters: SpeechOptions?) {
        super.init(frame: CGRect.zero)
        self.presentingController = presentingController
        self.speechConfigs = speechParameters
        if #available(iOS 10.0, *) {
            self.commonInit()
        } else {
            // Fallback on earlier versions
            print("Please use iOS 10.0 or upper")
        }
    }


    @available(iOS 10.0, *)
    private func commonInit() {
        print("Init SpeechInputView()")
        self.transcript = ""
    
        print("  + [CHECK] speechConfigs: \(self.speechConfigs)")
//        self.speechConfigs = SpeechOptions(serverURL: "wss://speech.deltaww.com", domain: "google", textAdaptDomain: "DELTA_Chatbot", enableTTS: true, enableVAD: true, nBest: 2, appId: "iOS-Chatbot2", userId: "guest123", microphoneAutoStop: false)
        
        self.configureUIView()
        
        //// label
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(white: 0.15, alpha: 1.0)
        label.text = "Click to Record"
        self.displayTextLabel = label
        self.addSubview(label)
        
        //// button
        let width = self.frame.midX + 150 // self.uiView.frame.midX + 100
        let height = self.frame.midY + 150 // self.uiView.frame.midY + 100

        let RecordButton: UIButton! = {
            let button = UIButton(frame: CGRect(x: width, y: height, width:155, height:155))
            button.isUserInteractionEnabled = true
            button.setImage(UIImage(named: "record-button"), for: .normal)
            // 要設定這個，才能用程式手動加constraint
            // https://stackoverflow.com/questions/36664850/programmatically-added-constraint-not-working
            // set translatesAutoresizingMaskIntoConstraints = false to any view you are settings constraints programatically.
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(ButtonPrintMessageTouched), for: .touchUpInside)
            
            // Constraints for Button
            let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
            let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
            
            self.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
            return button
        }()
        
        self.recordButton = RecordButton
        self.addSubview(RecordButton)
    }

    private func configureUIView() {
        self.uiView = UIView(frame: CGRect.zero)
        self.uiView.isUserInteractionEnabled = true
        self.addSubview(self.uiView)
    }

    private func configRecordingUI(_ isRecording: RecordingState){
        switch isRecording {
        case .IDLE:
            self.recordButton.setImage(UIImage(named: "record-button"), for: .normal)
            self.displayTextLabel.text = "Click to Record"
            self.displayTextLabel.textColor = .black

        case .RECORDING:
            self.recordButton.setImage(UIImage(named: "stop-button"), for: .normal)
            self.displayTextLabel.text = "Recording..."
            self.displayTextLabel.textColor = .red

        case .WAIT_CONNECTED:
            self.recordButton.setImage(UIImage(named: "record-button"), for: .normal)
            self.displayTextLabel.text = "Connecting to Speech Server..."
            self.displayTextLabel.textColor = .black

        case .WAIT_RECORDING_FINISH:
            self.recordButton.setImage(UIImage(named: "record-button"), for: .normal)
            self.displayTextLabel.text = "Click to Record"
            self.displayTextLabel.textColor = .black

        }
    }
    
//    func playSound(file:String, ext:String) -> Void {
//        let url = Bundle.main.url(forResource: file, withExtension: ext)!
//        do {
//            let player = try AVAudioPlayer(contentsOf: url)
//            player.prepareToPlay()
//            player.play()
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    @available(iOS 10.0, *)
    @IBAction private func ButtonPrintMessageTouched(_ sender: Any, forEvent event: UIEvent) {
        if self.displayTextLabel.text == "Click to Record" {
            configRecordingUI(.RECORDING)
//            self.speechConfigs.printMembers()
//            print(">> \(String(describing: self.speechConfigs.generateJson()))")
            startRecording()
        }
        else {
            configRecordingUI(.WAIT_RECORDING_FINISH)
//            self.recordButton.setImage(UIImage(named: "record-button"), for: .normal)
            stopRecording()
        }
    }
    
    @available(iOS 10.0, *)
    func startRecording() {
        // dicconnect previous connection if not yet disconnected from server
        if let socket = m_ws {
            if socket.status != .CLOSING && socket.status != .CLOSED {
                print("force socket.disconnect() for new recording request")
                socket.close()
            }
            m_ws = nil
        }
        
        // keep old text and append recognized text after it
        m_strOld = self.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        
        m_ws = WebSocketASR(delegate: self)
        // connect speech server, and start recording once websocket connected
        if let socket = m_ws {
            // create a sound ID, in this case its the tweet sound.
            // check system sound ID here: http://iphonedevwiki.net/index.php/AudioServices
            let systemSoundID: SystemSoundID = 1110
            AudioServicesPlaySystemSound(systemSoundID)
            
            socket.connect(strBaseURL: self.speechConfigs!.serverURL, strParameters: self.speechConfigs!.generateJson()!)
        }
    }
    
    func stopRecording() {
        // stop recording and wait connection close by server
        if let wsASR = m_ws {
            _ = wsASR.stopRecording()
        }

        // create a sound ID, in this case its the tweet sound.
        // check system sound ID here: http://iphonedevwiki.net/index.php/AudioServices
        let systemSoundID: SystemSoundID = 1111
        AudioServicesPlaySystemSound(systemSoundID)
    }
    

    private var m_strOld: String = ""
    private var m_ws : WebSocketASR? = nil
    private var m_timer:Timer!
    private var m_bRecvResultBeforeTimeout: Bool = false
    
    // timeer handler for auto Microphone
    @objc func timeOut() {
        m_timer.invalidate() // stop timer
        print("> time out...")
        // tap stop recording button if not yet got any result from server before timeout
        if let recorder = m_ws, recorder.isRecording && !m_bRecvResultBeforeTimeout {
            stopRecording()
        }
    }
    
    // MARK: WebSocketASR Delegate Functions
    
    func OnWSASRConnected(_ wsASR: WebSocketASR) {
        print("> on Socket conneted")
        configRecordingUI(.RECORDING)
        
        // check if user had update new speech options
        self.notificationCenter.addObserver(self, selector: #selector(UpdateSpeechOptions), name: NSNotification.Name(rawValue: "SpeechOptionDidChangeNotification"), object: nil)
        
        // reset previous transcriptions
        self.transcript = ""
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ChatInputBarTextShouldChangeNotification"), object: nil, userInfo: ["result": self.transcript])
        
        if wsASR.status == .CONNECTED {
            configRecordingUI(.RECORDING)
            self.m_bRecvResultBeforeTimeout = false
            // fire up timer, call timeOut() once 10 second reached
            // start timer in case of auto microphone
            self.m_timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.timeOut), userInfo: nil, repeats: false)
        }
        else {
            configRecordingUI(.IDLE)
        }
    }
    
    func OnWSASRResultCallback(_ wsASR: WebSocketASR, nbest aStrTopN: [String], _ isFinal: Bool) {
        if aStrTopN.count > 0 {
            print("ASR::TopN => \(aStrTopN)")
            self.transcript = aStrTopN[0]
        }
        else {
            print("ASR::TopN => Empty")
        }
        
        if isFinal {
            print("~final~")
            if let timer = self.m_timer {
                timer.invalidate()
            }
            if let recorder = self.m_ws, recorder.isRecording {
                stopRecording()
            }
            configRecordingUI(.WAIT_RECORDING_FINISH)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ChatInputBarTextShouldChangeNotification"), object: nil, userInfo: ["result": self.transcript])
    }
    
    func OnWSASRClosed(_ wsASR: WebSocketASR) {
        configRecordingUI(.IDLE)
        print("> Socket closed! @OnWSASRClosed()")
    }
    
    func OnWSASRError(_ wsASR: WebSocketASR) {
        configRecordingUI(.IDLE)
        print("> Socket has errors! @OnWSASRError()")
    }
    
    // update options when receive
    @objc func UpdateSpeechOptions(_ notification: Notification) {
        print("[Notf] <= ... ... ...  \(notification.userInfo!.keys) ... \(notification.userInfo!["options"])")
        self.speechConfigs = notification.userInfo!["options"] as! SpeechOptions
    }
}
