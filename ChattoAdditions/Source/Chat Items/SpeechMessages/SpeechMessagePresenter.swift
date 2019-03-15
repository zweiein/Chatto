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

open class SpeechMessagePresenter<ViewModelBuilderT, InteractionHandlerT>
: BaseMessagePresenter<SpeechBubbleView, ViewModelBuilderT, InteractionHandlerT> where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: SpeechMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT

    public let speechCellStyle: SpeechMessageCollectionViewCellStyleProtocol

    public init (
        messageModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: SpeechMessageCollectionViewCell,
        baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
        speechCellStyle: SpeechMessageCollectionViewCellStyleProtocol) {
            self.speechCellStyle = speechCellStyle
            super.init(
                messageModel: messageModel,
                viewModelBuilder: viewModelBuilder,
                interactionHandler: interactionHandler,
                sizingCell: sizingCell,
                cellStyle: baseCellStyle
            )
    }

    public final override class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(SpeechMessageCollectionViewCell.self, forCellWithReuseIdentifier: "speech-message")
    }

    public final override func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "speech-message", for: indexPath)
    }

    open override func createViewModel() -> ViewModelBuilderT.ViewModelT {
        let viewModel = self.viewModelBuilder.createViewModel(self.messageModel)
        let updateClosure = { [weak self] (old: Any, new: Any) -> Void in
            self?.updateCurrentCell()
        }
        viewModel.avatarImage.observe(self, closure: updateClosure)
        viewModel.image.observe(self, closure: updateClosure)
        viewModel.transferDirection.observe(self, closure: updateClosure)
        viewModel.transferProgress.observe(self, closure: updateClosure)
        viewModel.transferStatus.observe(self, closure: updateClosure)
        return viewModel
    }

    public var speechCell: SpeechMessageCollectionViewCell? {
        if let cell = self.cell {
            if let speechCell = cell as? SpeechMessageCollectionViewCell {
                return speechCell
            } else {
                assert(false, "Invalid cell was given to presenter!")
            }
        }
        return nil
    }

    open override func configureCell(_ cell: BaseMessageCollectionViewCell<SpeechBubbleView>, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionalConfiguration: (() -> Void)?) {
        guard let cell = cell as? SpeechMessageCollectionViewCell else {
            assert(false, "Invalid cell received")
            return
        }

        super.configureCell(cell, decorationAttributes: decorationAttributes, animated: animated) { () -> Void in
            cell.speechMessageViewModel = self.messageViewModel
            cell.speechMessageStyle = self.speechCellStyle
            additionalConfiguration?()
        }
    }

    public func updateCurrentCell() {
        if let cell = self.speechCell, let decorationAttributes = self.decorationAttributes {
            self.configureCell(cell, decorationAttributes: decorationAttributes, animated: self.itemVisibility != .appearing, additionalConfiguration: nil)
        }
    }
}
