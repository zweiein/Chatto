//
//  WebSocketASR.swift
//  ASRDemo
//
//  Created by 李允文 on 2018/4/9.
//  Copyright © 2018 dms. All rights reserved.
//

import Foundation
import SwiftWebSocket

protocol WebSocketASRDelegate {
    func OnWSASRConnected(_ wsASR: WebSocketASR) -> Void
    func OnWSASRClosed(_ wsASR: WebSocketASR) -> Void
    func OnWSASRError(_ wsASR: WebSocketASR) -> Void
    func OnWSASRResultCallback(_ wsASR: WebSocketASR, nbest aStrTopN: [String], _ isFinal: Bool) -> Void
}

class WebSocketASR {
    
    enum WebSocketState : Int {
        case UNDEFINE = -1
        /// The connection is not yet open.
        case CONNECTING = 0
        /// The connection is open and ready to communicate.
        case CONNECTED = 1
        /// The connection is in the process of closing.
        case CLOSING = 2
        /// The connection is closed or couldn't be opened.
        case CLOSED = 3
    }

    var status : WebSocketState {
        return m_nStatus
    }

    var isRecording : Bool {
        var isRecording: Bool = false
        if let recorder = m_streamRecord {
            isRecording = recorder.isRecording
        }
        return isRecording
    }

    init(delegate: WebSocketASRDelegate){
        m_delegate = delegate
    }
    
    func connect(strBaseURL : String, strParameters : String) -> Void {
        let strURLDir = "client/ws/speech"
        let strContentType = "content-type=audio/x-raw,+layout=(string)interleaved,+rate=(int)16000,+format=(string)S16LE,+channels=(int)1"
        var strURL: String
        
        if !strParameters.isEmpty, let escapedString = strParameters.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            strURL = "\(strBaseURL)/\(strURLDir)?\(strContentType)&parameters=\(escapedString)"
        } else {
            strURL = "\(strBaseURL)\(strURLDir)?\(strContentType)"
        }
        
        //request.timeoutInterval = 5
        let url = URL(string: strURL)
        let ws = WebSocket(strURL)
        //set this if you want to ignore SSL cert validation, so a self signed SSL certificate can be used.
        if let scheme = url?.scheme, scheme.range(of:"wss") != nil {
            ws.allowSelfSignedSSL = true
        }
        print("socket.connect(\(strURL)")
        
        ws.event.open = {
            print("websocket is connected")
            
            // start recording only if websocket connection successfully established
            self.m_streamRecord = StreamRecord(inRate: 44100.0, outRate:16000.0, writeDataFunc: self.writeData)
            
            if let recorder = self.m_streamRecord, recorder.start() {
                self.m_nStatus = .CONNECTED
                self.m_trans.reset()
            }else {
                self.m_nStatus = .CLOSING
                // close socket in case recording fail to start
                ws.close()
            }

            self.m_delegate?.OnWSASRConnected(self)
        }
        ws.event.close = { code, reason, clean in
            // confirmed disconnected socket is not previous connection
            if let m_ws = self.m_ws, m_ws == ws {
                if let recorder = self.m_streamRecord, recorder.isRecording {
                    recorder.stop()
                }
                self.m_nStatus = .CLOSING
            }
            print("websocket disconnected code:\(code) reason:\(reason) clean: \(clean)")
            self.m_delegate?.OnWSASRClosed(self)
        }
        ws.event.error = { error in
            self.m_nStatus = .CLOSING
            ws.close()
            if let m_ws = self.m_ws, m_ws == ws {
                if let recorder = self.m_streamRecord, recorder.isRecording {
                    recorder.stop()
                }
                self.m_nStatus = .CLOSING
            }
            print("error \(error)")
            self.m_delegate?.OnWSASRError(self)
        }
        ws.event.message = { message in
            if let text = message as? String {
                print("Received text: \(text)")

                if let delegate = self.m_delegate {
                    if let result = parseResultJSON(string: text) {
                        _ = self.m_trans.add(json: text)
                        delegate.OnWSASRResultCallback(self, nbest: self.m_trans.m_aStrNBest, result.isFinal)
                    }else {
                        _ = self.m_trans.add(text: text, final: true)
                        delegate.OnWSASRResultCallback(self, nbest: self.m_trans.m_aStrNBest, true)
                    }
                }
            } else if let data = message as? Data {
                print("Received data: \(data.count)")
            }
        }
        
        m_ws = ws
    }

    func close() -> Void {
        if let ws = m_ws {
            m_nStatus = .CLOSING
            ws.close()
        }
        if let recorder = m_streamRecord, recorder.isRecording {
            recorder.stop()
        }
    }

    func stopRecording() -> Bool {
        var bOK: Bool = false
        if let recorder = m_streamRecord {
            recorder.stop()
            bOK = true
        }
        
        if let ws = m_ws {
            if ws.readyState == .open {
                // send EOS and wait final result and disconnection from server
                ws.send(text: "EOS")
            }else{
                print("skip EOS sent for disconnected connection")
            }
        }
        
        return bOK
    }
    
    func play() {
        if let recorder = m_streamRecord {
            recorder.play()
        }
    }

    // MARK: Write Data/Text Methods over websocket
    
    private func writeData(data: Data) -> Void {
        if let ws = m_ws {
            ws.send(data: data)
        }else{
            print("writeData using broken websocket")
        }
    }
    
    private func writeText(text: String) -> Void {
        if let ws = m_ws {
            ws.send(text: text)
        }else{
            print("writeText using broken websocket")
        }
    }

    private var m_ws: WebSocket? = nil
    private var m_trans = Transcription()
    private var m_streamRecord :StreamRecord? = nil

    private var m_nStatus :WebSocketState = .UNDEFINE
    private var m_delegate: WebSocketASRDelegate? = nil
}

