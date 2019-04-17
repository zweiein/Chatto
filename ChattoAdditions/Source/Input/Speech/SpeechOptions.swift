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

struct SpeechOptions {
    var domain: String
    var serverURL: String
    var textAdaptDomain: String
    var enableTTS: Bool
    var enableVAD: Bool
    var nBest: Int
    var userDefineDict: [String:String]?
    var appId: String
    var userId: String
    var words:[String]?
    var microphoneAutoStop: Bool
    
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
    }
    
//    init(serverURL: String, domain: String, textAdaptDomain: String?){
//        self.serverURL = serverURL
//        self.domain = domain
//        self.textAdaptDomain = textAdaptDomain
//    }
//
//    init(serverURL: String, domain: String, appId: String?, userId: String?, textAdaptDomain: String?){
//        self.serverURL = serverURL
//        self.domain = domain
//        self.appId = appId
//        self.userId = userId
//        self.textAdaptDomain = textAdaptDomain
//    }
//
//    init(serverURL: String, domain: String){
//        self.init(serverURL: serverURL, domain: domain, textAdaptDomain: nil)
//    }
    
    mutating func addUserDefine(entry: [String:String]) -> Bool {
        var bSucc = false
        if nil == self.userDefineDict {
            self.userDefineDict = [String:String]()
        }
        if nil != self.userDefineDict {
            for e in entry {
                self.userDefineDict!.updateValue(e.value, forKey: e.key)
            }
            bSucc = true
        }
        
        return bSucc
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
        print("\t+ userDefineDict: \(self.userDefineDict)")
        print("\t+ microphoneAutoStop: \(self.microphoneAutoStop)")
        print("\t+ words: \(self.words)")
    }
    
//    func composeOptionsToJson() -> String? {
//        var strParamJson: String? = nil
//
//        let whatDomain = astrASRDomains[pvDomain.selectedRow(inComponent: DOMAINTYPE.ASRDOMAIN.rawValue)]
//        let whatTextAdaptDomain = astrTextAdaptDomains[pvDomain.selectedRow(inComponent: DOMAINTYPE.TEXTADAPTDOMAIN.rawValue)]
//
//        var param = parameters_t(domain: whatDomain)
//        param.textadaptdomain = whatTextAdaptDomain.isEmpty ? nil:whatTextAdaptDomain
//
//        var userdefine = [String: String]()
//        if let strAppID = tfAppID.text, !strAppID.isEmpty  {
//            let strAppIDTrim = strAppID.trimmingCharacters(in: .whitespacesAndNewlines)
//            if !strAppIDTrim.isEmpty {
//                userdefine[Constants.APPID] = strAppIDTrim
//            }
//        }
//        if let strUserID = tfUserID.text, !strUserID.isEmpty {
//            let strUserIDTrim = strUserID.trimmingCharacters(in: .whitespacesAndNewlines)
//            if !strUserIDTrim.isEmpty {
//                userdefine[Constants.USERID] = strUserIDTrim
//            }
//        }
//        if let strNBest = tfNBest.text, !strNBest.isEmpty {
//            let strNBestTrim = strNBest.trimmingCharacters(in: .whitespacesAndNewlines)
//            if !strNBestTrim.isEmpty {
//                if let nBest = Int(strNBestTrim) {
//                    param.nbest = nBest;
//                }else {
//                    print("NBest \(strNBestTrim) failed to convert to Int")
//                }
//            }
//        }
//
//        if userdefine.count > 0 {
//            _ = param.addUDF(entry: userdefine)
//        }
//
//        // compose parameter json string
//        let encoder = JSONEncoder()
//        //encoder.outputFormatting = .prettyPrinted
//
//        do {
//            let data = try encoder.encode(param)
//            strParamJson = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/")
//            //            if let str = strParamJson {
//            //                print("parameter JSON:\n\(str)\n")
//            //            }
//        }catch {
//            print("Exception: JSONSerialization.encorder(): \(error)")
//        }
//
//        return strParamJson
//    }
    
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
