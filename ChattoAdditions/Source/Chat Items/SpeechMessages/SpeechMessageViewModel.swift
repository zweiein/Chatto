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

public enum TransferDirection {
    case upload
    case download
}

public enum TransferStatus {
    case idle
    case transfering
    case failed
    case success
}

public protocol SpeechMessageViewModelProtocol: DecoratedMessageViewModelProtocol {
    var transferDirection: Observable<TransferDirection> { get set }
    var transferProgress: Observable<Double> { get  set } // in [0,1]
    var transferStatus: Observable<TransferStatus> { get set }
    var image: Observable<UIImage?> { get set }
    var imageSize: CGSize { get }
    var cellAccessibilityIdentifier: String { get }
    var bubbleAccessibilityIdentifier: String { get }
}

open class SpeechMessageViewModel<speechMessageModelT: SpeechMessageModelProtocol>: SpeechMessageViewModelProtocol {
    public var speechMessage: SpeechMessageModelProtocol {
        return self._speechMessage
    }
    public let _speechMessage: speechMessageModelT // Can't make speechMessage: speechMessageModelT: https://gist.github.com/diegosanchezr/5a66c7af862e1117b556
    public var transferStatus: Observable<TransferStatus> = Observable(.idle)
    public var transferProgress: Observable<Double> = Observable(0)
    public var transferDirection: Observable<TransferDirection> = Observable(.download)
    public var image: Observable<UIImage?>
    open var imageSize: CGSize {
        return self.speechMessage.imageSize
    }
    public let cellAccessibilityIdentifier = "chatto.message.speech.cell"
    public let bubbleAccessibilityIdentifier = "chatto.message.speech.bubble"
    public let messageViewModel: MessageViewModelProtocol
    open var isShowingFailedIcon: Bool {
        return self.messageViewModel.isShowingFailedIcon || self.transferStatus.value == .failed
    }

    public init(speechMessage: speechMessageModelT, messageViewModel: MessageViewModelProtocol) {
        self._speechMessage = speechMessage
        self.image = Observable(speechMessage.image)
        self.messageViewModel = messageViewModel
    }

    open func willBeShown() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }

    open func wasHidden() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
}

open class SpeechMessageViewModelDefaultBuilder<speechMessageModelT: SpeechMessageModelProtocol>: ViewModelBuilderProtocol {
    public init() {}

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    open func createViewModel(_ model: speechMessageModelT) -> SpeechMessageViewModel<speechMessageModelT> {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(model)
        let SpeechMessageViewModel = SpeechMessageViewModel(speechMessage: model, messageViewModel: messageViewModel)
        return SpeechMessageViewModel
    }

    open func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is speechMessageModelT
    }
}
