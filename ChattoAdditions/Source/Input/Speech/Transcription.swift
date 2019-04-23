//
//  Transcription.swift
//
//  Created by Alan Lee on 03/13/18.
//  Copyright (c) 2018 Delta Electronics, inc. All rights reserved.
//

import Foundation

class Transcription: CustomStringConvertible {
    init() {
        m_strList = [String]()
        m_aStrNBest = [String]()
        m_nIndex = -1
    }

    func reset() {
        m_strList = [String]()
        m_nIndex = -1
    }
    
    func add(json strJson: String) -> Bool {
        var bSucc = false
        if let result = parseResultJSON(string: strJson) {
            if let aStrNBest = result.aStrNBest {
                bSucc = self.add(nbest: aStrNBest, final: result.isFinal)
            }
        }
        return bSucc
    }
    
    func add(text strResult: String, final isFinal: Bool) -> Bool {
        check_remove_not_final()
        m_strList.append(strResult)
        if isFinal {
            m_nIndex += 1
            m_aStrNBest = [String]()
            m_aStrNBest.append(description)
        }
        return true
    }

    func add(nbest aStrResults: [String], final isFinal: Bool) -> Bool {
        if isFinal {
            check_remove_not_final()
            let strOld = description
            let strTop0Result = aStrResults.count>0 ? aStrResults[0]:""
            m_strList.append(strTop0Result)
            m_nIndex += 1
            
            m_aStrNBest = [String]()
            for strTopN in aStrResults {
                m_aStrNBest.append(strOld + strTopN)
            }
        }else if aStrResults.count > 0 {
            return add(text: aStrResults[0], final: isFinal)
        }
        return true
    }

    private func  check_remove_not_final() {
        if m_strList.count > (m_nIndex+1) {
            m_strList.remove(at: m_nIndex+1)
        }
    }
    
    public var description: String {
        var strOut = ""
        for(_, text) in m_strList.enumerated() {
            strOut += text
        }
        return strOut
    }

    var m_strList :[String]
    var m_aStrNBest : [String]
    var m_nIndex  :Int
}
