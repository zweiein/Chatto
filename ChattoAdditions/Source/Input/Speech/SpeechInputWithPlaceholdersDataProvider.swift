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

import PhotosUI

protocol SpeechInputDataProviderDelegate: class {
    func handleSpeechInputDataProviderUpdate(_ dataProvider: SpeechInputDataProviderProtocol, updateBlock: @escaping () -> Void)
}

protocol SpeechInputDataProviderProtocol: class {
    var delegate: SpeechInputDataProviderDelegate? { get set }
    var count: Int { get }
    @discardableResult
    func requestPreviewImage(at index: Int,
                             targetSize: CGSize,
                             completion: @escaping SpeechInputDataProviderCompletion) -> SpeechInputDataProviderAudioRequestProtocol
    @discardableResult
    func requestFullImage(at index: Int,
                          progressHandler: SpeechInputDataProviderProgressHandler?,
                          completion: @escaping SpeechInputDataProviderCompletion) -> SpeechInputDataProviderAudioRequestProtocol
    func fullImageRequest(at index: Int) -> SpeechInputDataProviderAudioRequestProtocol?
}

typealias SpeechInputDataProviderProgressHandler = (Double) -> Void
typealias SpeechInputDataProviderCompletion = (SpeechInputDataProviderResult) -> Void

enum SpeechInputDataProviderResult {
    case success(UIImage)
    case error(Error?)

    var image: UIImage? {
        guard case let .success(resultImage) = self else { return nil }
        return resultImage
    }
}

protocol SpeechInputDataProviderAudioRequestProtocol: class {
    var requestId: Int32 { get }
    var progress: Double { get }

    func observeProgress(with progressHandler: SpeechInputDataProviderProgressHandler?,
                         completion: SpeechInputDataProviderCompletion?)
    func cancel()
}

final class SpeechInputWithPlaceholdersDataProvider: SpeechInputDataProviderProtocol, SpeechInputDataProviderDelegate {
    weak var delegate: SpeechInputDataProviderDelegate?
    private let speechDataProvider: SpeechInputDataProviderProtocol
    private let placeholdersDataProvider: SpeechInputDataProviderProtocol

    init(speechDataProvider: SpeechInputDataProviderProtocol, placeholdersDataProvider: SpeechInputDataProviderProtocol) {
        self.speechDataProvider = speechDataProvider
        self.placeholdersDataProvider = placeholdersDataProvider
        self.speechDataProvider.delegate = self
    }

    var count: Int {
        return max(self.speechDataProvider.count, self.placeholdersDataProvider.count)
    }

    @discardableResult
    func requestPreviewImage(at index: Int,
                             targetSize: CGSize,
                             completion: @escaping SpeechInputDataProviderCompletion) -> SpeechInputDataProviderAudioRequestProtocol {
        if index < self.speechDataProvider.count {
            return self.speechDataProvider.requestPreviewImage(at: index, targetSize: targetSize, completion: completion)
        } else {
            return self.placeholdersDataProvider.requestPreviewImage(at: index, targetSize: targetSize, completion: completion)
        }
    }

    @discardableResult
    func requestFullImage(at index: Int,
                          progressHandler: SpeechInputDataProviderProgressHandler?,
                          completion: @escaping SpeechInputDataProviderCompletion) -> SpeechInputDataProviderAudioRequestProtocol {
        if index < self.speechDataProvider.count {
            return self.speechDataProvider.requestFullImage(at: index, progressHandler: progressHandler, completion: completion)
        } else {
            return self.placeholdersDataProvider.requestFullImage(at: index, progressHandler: progressHandler, completion: completion)
        }
    }

    func fullImageRequest(at index: Int) -> SpeechInputDataProviderAudioRequestProtocol? {
        if index < self.speechDataProvider.count {
            return self.speechDataProvider.fullImageRequest(at: index)
        } else {
            return self.placeholdersDataProvider.fullImageRequest(at: index)
        }
    }

    // MARK: SpeechInputDataProviderDelegate

    func handleSpeechInputDataProviderUpdate(_ dataProvider: SpeechInputDataProviderProtocol, updateBlock: @escaping () -> Void) {
        self.delegate?.handleSpeechInputDataProviderUpdate(self, updateBlock: updateBlock)
    }
}
