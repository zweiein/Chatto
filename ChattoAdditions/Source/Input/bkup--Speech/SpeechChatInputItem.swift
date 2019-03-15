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

open class SpeechChatInputItem: ChatInputItemProtocol {
    typealias Class = SpeechChatInputItem

    public var speechInputHandler: ((UIImage) -> Void)?
    public var microphonePermissionHandler: (() -> Void)?
    public var speechPermissionHandler: (() -> Void)?
    public weak var presentingController: UIViewController?

    let buttonAppearance: TabInputButtonAppearance
    let inputViewAppearance: PhotosInputViewAppearance
    public init(presentingController: UIViewController?,
                tabInputButtonAppearance: TabInputButtonAppearance = SpeechChatInputItem.createDefaultButtonAppearance(),
                inputViewAppearance: SpeechInputViewAppearance = SpeechChatInputItem.createDefaultInputViewAppearance()) {
        self.presentingController = presentingController
        self.buttonAppearance = tabInputButtonAppearance
        self.inputViewAppearance = inputViewAppearance
    }

    public static func createDefaultButtonAppearance() -> TabInputButtonAppearance {
        let images: [UIControlStateWrapper: UIImage] = [
            UIControlStateWrapper(state: .normal): UIImage(named: "mic-icon-unselected", in: Bundle(for: Class.self), compatibleWith: nil)!,
            UIControlStateWrapper(state: .selected): UIImage(named: "mic-icon-selected", in: Bundle(for: Class.self), compatibleWith: nil)!,
            UIControlStateWrapper(state: .highlighted): UIImage(named: "mic-icon-selected", in: Bundle(for: Class.self), compatibleWith: nil)!
        ]
        return TabInputButtonAppearance(images: images, size: nil)
    }

    public static func createDefaultInputViewAppearance() -> PhotosInputViewAppearance {
        return SpeechInputViewAppearance(liveCameraCellAppearence: LiveCameraCellAppearance.createDefaultAppearance())
    }

    lazy private var internalTabView: UIButton = {
        return TabInputButton.makeInputButton(withAppearance: self.buttonAppearance, accessibilityID: "speech.chat.input.view")
    }()

    lazy var speechInputView: SpeechInputViewProtocol = {
        let speechInputView = SpeechInputView(presentingController: self.presentingController, appearance: self.inputViewAppearance)
        speechInputView.delegate = self
        return speechInputView
    }()

    open var selected = false {
        didSet {
            self.internalTabView.isSelected = self.selected
        }
    }

    // MARK: - ChatInputItemProtocol

    open var presentationMode: ChatInputItemPresentationMode {
        return .customView
    }

    open var showsSendButton: Bool {
        return false
    }

    open var inputView: UIView? {
        return self.speechInputView as? UIView
    }

    open var tabView: UIView {
        return self.internalTabView
    }

    open func handleInput(_ input: AnyObject) {
        if let image = input as? UIImage {
            self.speechInputHandler?(image)
        }
    }
}

// MARK: - SpeechChatInputItem
extension SpeechChatInputItem: SpeechInputViewDelegate {
    func inputView(_ inputView: SpeechInputViewProtocol, didSelectImage image: UIImage) {
        self.speechInputHandler?(image)
    }

    func inputViewDidRequestMicrophonePermission(_ inputView: SpeechInputViewProtocol) {
        self.microphonePermissionHandler?()
    }

    func inputViewDidRequestSpeechLibraryPermission(_ inputView: SpeechInputViewProtocol) {
        self.speechPermissionHandler?()
    }
}
