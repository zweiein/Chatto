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

import Foundation
import AVFoundation

open class SpeechChatInputItem {
    typealias Class = SpeechChatInputItem
    public var speechInputHandler: ((String) -> Void)?
    public weak var presentingController: UIViewController?
    public weak var speechParameters: SpeechOptions?

    let buttonAppearance: TabInputButtonAppearance
    public init(tabInputButtonAppearance: TabInputButtonAppearance = SpeechChatInputItem.createDefaultButtonAppearance(),
                presentingController: UIViewController?) {
        self.buttonAppearance = tabInputButtonAppearance
        self.presentingController = presentingController
    }
    
    public func UpdateSpeechOptions(parameters: SpeechOptions) {
        self.speechParameters = parameters
    }

    public static func createDefaultButtonAppearance() -> TabInputButtonAppearance {
        let images: [UIControlStateWrapper: UIImage] = [
            UIControlStateWrapper(state: .normal): UIImage(named: "mic-icon-unselected", in: Bundle(for: SpeechChatInputItem.self), compatibleWith: nil)!,
            UIControlStateWrapper(state: .selected): UIImage(named: "mic-icon-selected", in: Bundle(for: SpeechChatInputItem.self), compatibleWith: nil)!,
            UIControlStateWrapper(state: .highlighted): UIImage(named: "mic-icon-selected", in: Bundle(for: SpeechChatInputItem.self), compatibleWith: nil)!
        ]
        return TabInputButtonAppearance(images: images, size: CGSize(width: 20, height: 20))
    }

    lazy var speechInputView: SpeechInputViewProtocol = {
        let speechInputView = SpeechInputView(presentingController: self.presentingController, speechParameters: self.speechParameters)
        return speechInputView
    }()

//    lazy var speechInputView: SpeechInputViewProtocol = {
//        let speechInputView = SpeechInputView(presentingController: self.presentingController)
//        return speechInputView
//    }()
    
    lazy fileprivate var internalTabView: TabInputButton = {
        return TabInputButton.makeInputButton(withAppearance: self.buttonAppearance, accessibilityID: "speech.chat.input.view")
    }()

    open var selected = false {
        didSet {
            self.internalTabView.isSelected = self.selected
        }
    }
}

// MARK: - ChatInputItemProtocol
extension SpeechChatInputItem: ChatInputItemProtocol {
    public var presentationMode: ChatInputItemPresentationMode {
        return .keyboard
    }

    public var showsSendButton: Bool {
        return true
    }

    public var inputView: UIView? {
        return self.speechInputView as? UIView
    }

    public var tabView: UIView {
        return self.internalTabView
    }

    public func handleInput(_ input: AnyObject) {
        if let text = input as? String {
            self.speechInputHandler?(text)
        }
    }
}

