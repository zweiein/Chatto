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
import Photos
import Chatto
import AVFoundation

protocol SpeechInputViewViewStyleProtocol {
    func bubbleImage(viewModel viewModel: AudioMessageViewModelProtocol) -> UIImage
    func bubbleImageBorder(viewModel viewModel: AudioMessageViewModelProtocol) -> UIImage?
}

public class SpeechInputViewView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {
    
    public var viewContext: ViewContext = .Normal
    public var animationDuration: CFTimeInterval = 0.33
    public var preferredMaxLayoutWidth: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.autoresizesSubviews = false
        self.addSubview(self.bubbleImageView)
        self.addSubview(self.voiceView)
        self.addSubview(self.durationLabel)
    }
    
    private var borderImageView: UIImageView = UIImageView()
    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.addSubview(self.borderImageView)
        return imageView
    }()
    
    private lazy var voiceView: UIImageView = {
        let voiceView = UIImageView()
        // animation initial state
        voiceView.image = R.image.chat_voice_white_outgoing_anim3()
        voiceView.animationImages = [
            R.image.chat_voice_white_outgoing_anim1()!,
            R.image.chat_voice_white_outgoing_anim2()!,
            R.image.chat_voice_white_outgoing_anim3()!
        ]
        voiceView.animationDuration = 1

        
        return voiceView
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.00)
        label.font = label.font.fontWithSize(14)
        
        return label
    }()
    
    var viewModel: AudioMessageViewModelProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    var style: SpeechInputViewViewStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    public private(set) var isUpdating: Bool = false
    public func performBatchUpdates(updateClosure: () -> Void, animated: Bool, completion: (() ->())?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animateWithDuration(self.animationDuration, animations: updateAndRefreshViews, completion: { (finished) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
    
    public func updateViews() {
        if self.viewContext == .Sizing { return }
        if isUpdating { return }
        guard let viewModel = self.viewModel, style = self.style else { return }
        
        self.updateVoiceView()
        let bubbleImage = style.bubbleImage(viewModel: viewModel)
        let borderImage = style.bubbleImageBorder(viewModel: viewModel)
        if self.bubbleImageView.image != bubbleImage {
            self.bubbleImageView.image = bubbleImage
        }
        if self.borderImageView.image != borderImage {
            self.borderImageView.image = borderImage
        }
        self.durationLabel.text = "\(viewModel.duration)″"
    }
    
    public func playAnimation() {
        // make the animation start
        self.voiceView.startAnimating()
    }
    
    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = self.calculateTextBubbleLayout(maximumWidth: self.preferredMaxLayoutWidth)
        self.bubbleImageView.bma_rect = layout.bubbleFrame
        self.borderImageView.bma_rect = self.bubbleImageView.bounds
        let voiceIconHeight: CGFloat = 15.0
        self.voiceView.frame = CGRectMake(layout.bubbleFrame.width - 36, (layout.bubbleFrame.height - voiceIconHeight) / 2, voiceIconHeight, voiceIconHeight)
        self.durationLabel.frame = CGRectMake(-21, layout.bubbleFrame.height / 2, 20, 20)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        return self.calculateTextBubbleLayout(maximumWidth: size.width).size
    }
    
    public var canCalculateSizeInBackground: Bool {
        return true
    }
    
    // MARK: Private Helper Methods
    private func updateVoiceView() {
        
    }
    
    private func calculateTextBubbleLayout(maximumWidth maximumWidth: CGFloat) -> SpeechInputViewLayoutModel {
        let layoutContext = SpeechInputViewLayoutModel.LayoutContext(
            preferredMaxLayoutWidth: maximumWidth
        )
        let layoutModel = SpeechInputViewLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()
        
        return layoutModel
    }
}


private class SpeechInputViewLayoutModel {
    var bubbleFrame: CGRect = CGRect.zero
    var size: CGSize = CGSize.zero
    
    struct LayoutContext {
        let preferredMaxLayoutWidth: CGFloat
        //        let textInsets: UIEdgeInsets
    }
    
    let layoutContext: LayoutContext
    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }
    
    func calculateLayout() {
        //        let textHorizontalInset = self.layoutContext.textInsets.bma_horziontalInset
        //        let maxTextWidth = self.layoutContext.preferredMaxLayoutWidth - textHorizontalInset
        //        let textSize = self.textSizeThatFitsWidth(maxTextWidth)
        //        let bubbleSize = textSize.bma_outsetBy(dx: textHorizontalInset, dy: self.layoutContext.textInsets.bma_verticalInset)
        let bubbleSize = CGSizeMake(75.0, 35.0)
        self.bubbleFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
        self.size = bubbleSize
    }
}