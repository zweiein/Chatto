//
//  ResultParse.swift
//
//  Created by Alan Lee on 03/13/18.
//  Copyright (c) 2018 Delta Electronics, inc. All rights reserved.
//

import Foundation

/* Path for JSON files bundled with the Playground */

struct stResult_t {
    init() {
        strTranscript = ""
        isFinal = false
    }
    var strTranscript : String
    var aStrNBest : [String]?
    var isFinal : Bool
}

struct HypWord_t: Codable {
    var score, start, end: Double?
    var transcript: String
}

struct HypSentence_t: Codable {
    var score, start, end: Double?
    var transcript: String
    var concept, originaltranscript: String?
    var words: [HypWord_t]?
    
    private enum CodingKeys : String, CodingKey {
        case score, start, end, transcript, concept, originaltranscript = "original-transcript", words
    }
}

struct HypResult_t: Codable {
    var hypotheses: [HypSentence_t]
    var domain: String
    var final: Bool
}

struct Hyp_t: Codable {
    var result: HypResult_t
    var id: String
    var status, segment: Int
}

func parseResultJSON(data rawJSONData: Data) -> stResult_t? {
    var retResult : stResult_t? = nil
    if let hyp = try? JSONDecoder().decode(Hyp_t.self, from: rawJSONData) {
        retResult  = stResult_t()
        //        print(hyp)
        if hyp.result.hypotheses.count > 0 {
            retResult!.strTranscript = hyp.result.hypotheses[0].transcript
        }
        retResult!.aStrNBest = [String]()
        for hyp in hyp.result.hypotheses {
            retResult!.aStrNBest!.append(hyp.transcript)
        }
        retResult!.isFinal = hyp.result.final
    }
    
    return retResult
}

func parseResultJSON(string strJSON: String) -> stResult_t? {
    let rawJSONData = strJSON.data(using: .utf8)!
    return parseResultJSON(data: rawJSONData)
}
