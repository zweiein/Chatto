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
    var domain: String
    var serverURL: String
    var textAdaptDomain: String
    var enableTTS: Bool
    var enableVAD: Bool
    var nBest: Int
    var userDefineDict: [String: Any]?
    var paramDict: [String: Any]?
    var appId: String
    var userId: String
    var words:[String]?
    var microphoneAutoStop: Bool
    var defaultJsonString: String?
    
    init(serverURL: String, domain: String, textAdaptDomain: String, enableTTS: Bool, enableVAD: Bool, nBest: Int, appId: String, userId: String, microphoneAutoStop: Bool){
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
        self.paramDict!["vad-enable"] = self.enableVAD
        self.paramDict!["nbest"] = self.nBest
        
        self.userDefineDict = Dictionary<String, Any>()
        self.userDefineDict!["app-id"] = self.appId
        self.userDefineDict!["user-id"] = self.userId
        
        self.paramDict!["user-define"] = self.userDefineDict
        
        self.defaultJsonString = "{\"domain\":\"google\",\"user-define\":{\"user-id\":\"guest2\",\"app-id\":\"iOS-Chatbot2\"},\"vad-enable\":true,\"nbest\":1}"
    }
    
    init(){
        self.domain = "google"
        self.serverURL = "wss://speech.deltaww.com"
        self.textAdaptDomain = "DELTA_Chatbot"
        self.enableTTS = false
        self.enableVAD = true
        self.nBest = 1
        self.appId = "iOS-Chatbot"
        self.userId = "guest"
        self.microphoneAutoStop = false
        
        self.paramDict = Dictionary<String, Any>()
        self.paramDict!["domain"] = self.domain
        self.paramDict!["vad-enable"] = self.enableVAD
        self.paramDict!["nbest"] = self.nBest
        
        self.userDefineDict = Dictionary<String, Any>()
        self.userDefineDict!["app-id"] = self.appId
        self.userDefineDict!["user-id"] = self.userId
        
        self.paramDict!["user-define"] = self.userDefineDict
        self.defaultJsonString = "{\"domain\":\"google\",\"user-define\":{\"user-id\":\"guest2\",\"app-id\":\"iOS-Chatbot2\"},\"vad-enable\":true,\"nbest\":1}"
    }
    
    func printMembers() {
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
    
    func generateJson() -> String? {
        let jsonData = try! JSONSerialization.data(withJSONObject: self.paramDict ?? self.defaultJsonString!)
        let jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        print("\t+ json: \(jsonString!)")
        return jsonString!
    }
    
//    mutating func addWords(words: [String]) -> Bool {
//        var bSucc = false
//        if nil == self.words {
//            self.words = [String]()
//        }
//        if nil != self.words {
//            for w in words {
//                self.words!.append(w)
//            }
//            bSucc = true
//        }
//
//        return bSucc
//    }
//
//    private enum CodingKeys : String, CodingKey {
//        case domain, vadenable = "vad-enable", textadaptdomain = "text-adapt-domain", userdefine = "user-define", words, nbest
//    }
}
