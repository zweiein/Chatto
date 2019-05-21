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
import Chatto

open class SpeechOptions {
    public var domain: String
    public var serverURL: String
    public var textAdaptDomain: String
    public var enableTTS: Bool
    public var enableVAD: Bool
    public var nBest: Int
    public var userDefineDict: [String: Any]?
    public var paramDict: [String: Any]?
    public var appId: String
    public var userId: String
    public var words:[String]?
    public var microphoneAutoStop: Bool
    public var defaultJsonString: String?
    
    public init(serverURL: String, domain: String, textAdaptDomain: String, enableTTS: Bool, enableVAD: Bool, nBest: Int, appId: String, userId: String, microphoneAutoStop: Bool){
        self.domain = domain
        self.serverURL = serverURL
        self.textAdaptDomain = textAdaptDomain
        self.enableTTS = enableTTS
        self.enableVAD = enableTTS
        self.nBest = nBest
        self.appId = appId
        self.userId = userId
        self.microphoneAutoStop = microphoneAutoStop
        
        self.paramDict = Dictionary<String, Any>()
        self.paramDict!["domain"] = self.domain
        self.paramDict!["text-adapt-domain"] = self.textAdaptDomain
        self.paramDict!["vad-enable"] = self.enableVAD
        self.paramDict!["nbest"] = self.nBest
        
        self.userDefineDict = Dictionary<String, Any>()
        self.userDefineDict!["app-id"] = self.appId
        self.userDefineDict!["user-id"] = self.userId
        
        self.paramDict!["user-define"] = self.userDefineDict
        
        self.defaultJsonString = "{\"domain\":\"google\",\"text-adapt-domain\":\"DELTA_Chatbot\",\"user-define\":{\"user-id\":\"guest2\",\"app-id\":\"iOS-Chatbot2\"},\"vad-enable\":true,\"nbest\":2}"
    }
    
    public init(){
        self.domain = "google"
        self.serverURL = "wss://speech.deltaww.com"
        self.textAdaptDomain = "DELTA_Chatbot"
        self.enableTTS = false
        self.enableVAD = true
        self.nBest = 2
        self.appId = "iOS-Chatbot"
        self.userId = "guest"
        self.microphoneAutoStop = false
        
        self.paramDict = Dictionary<String, Any>()
        self.paramDict!["domain"] = self.domain
        self.paramDict!["text-adapt-domain"] = self.textAdaptDomain
        self.paramDict!["vad-enable"] = self.enableVAD
        self.paramDict!["nbest"] = self.nBest
        
        self.userDefineDict = Dictionary<String, Any>()
        self.userDefineDict!["app-id"] = self.appId
        self.userDefineDict!["user-id"] = self.userId
        
        self.paramDict!["user-define"] = self.userDefineDict
        self.defaultJsonString = "{\"domain\":\"google\",\"text-adapt-domain\":\"DELTA_Chatbot\",\"user-define\":{\"user-id\":\"guest2\",\"app-id\":\"iOS-Chatbot2\"},\"vad-enable\":true,\"nbest\":2}"
    }
    
    public func printMembers() {
        print("[S]SpeechOptions -> printMembers()")
        print("\t+ domain: \(self.domain)")
        print("\t+ serverURL: \(self.serverURL)")
        print("\t+ textAdaptDomain: \(self.textAdaptDomain)")
        print("\t+ enableVAD: \(self.enableVAD)")
        print("\t+ enableTTS: \(self.enableTTS)")
        print("\t+ nBest: \(self.nBest)")
        print("\t+ appId: \(self.appId)")
        print("\t+ userId: \(self.userId)")
        print("\t+ userDefineDict: \(self.userDefineDict!)")
        print("\t+ microphoneAutoStop: \(self.microphoneAutoStop)")
        print("\t+ words: \(self.words)")
        print("==============\n\t+ params: \(self.paramDict!)")
    }
    
    public func updateParamDict() {
        self.paramDict!["domain"] = self.domain
        self.paramDict!["text-adapt-domain"] = self.textAdaptDomain
        self.paramDict!["vad-enable"] = self.enableVAD
        self.paramDict!["nbest"] = self.nBest
        
        self.userDefineDict!["app-id"] = self.appId
        self.userDefineDict!["user-id"] = self.userId
        self.paramDict!["user-define"] = self.userDefineDict
    }
    
    public func generateJson() -> String? {
        let jsonData = try! JSONSerialization.data(withJSONObject: self.paramDict ?? self.defaultJsonString!)
        let jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        print("-----------------------------------------------------------")
        print("\t+ JSON was: \(jsonString!)")
        print("-----------------------------------------------------------")
        return jsonString!
    }
}
