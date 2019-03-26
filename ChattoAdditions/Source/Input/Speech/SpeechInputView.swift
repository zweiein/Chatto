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

// public struct PhotosInputViewAppearance {
//     public var liveCameraCellAppearence: LiveCameraCellAppearance
//     public init(liveCameraCellAppearence: LiveCameraCellAppearance) {
//         self.liveCameraCellAppearence = liveCameraCellAppearence
//     }
// }

protocol SpeechInputViewProtocol {
    var delegate: SpeechInputViewDelegate? { get set }
    var presentingController: UIViewController? { get }
}

protocol SpeechInputViewDelegate: class {
    func inputView(_ inputView: SpeechInputViewProtocol, didSelectImage image: UIImage)
}

class SpeechInputView: UIView, SpeechInputViewProtocol {
    fileprivate var uiView: UIView!

    weak var delegate: SpeechInputViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    weak var presentingController: UIViewController?
    init(presentingController: UIViewController?) {
        super.init(frame: CGRect.zero)
        self.presentingController = presentingController
        self.commonInit()
    }

    // deinit {
    //     self.uiView.dataSource = nil
    //     self.uiView.delegate = nil
    // }

    private func commonInit() {
        self.configureUIView()
        print("initialize SpeechInputView.commonInit()")
    }

    private func configureUIView() {
        self.uiView = UIView(frame: CGRect.zero)
        self.addSubview(self.uiView)
        
        let printMessageButton = UIButton()      
        printMessageButton = UIButton(frame: CGRect(x:0, y:335, width:120, height:40))
        printMessageButton.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
        printMessageButton.setTitle("Show", forState: .Normal)
        printMessageButton.tag = 3
        printMessageButton.addTarget(self, action: "ButtonPrintMessageTouched:", forControlEvents: .TouchUpInside)       
        self.uiView.addSubview(printMessageButton)
    }

    func ButtonPrintMessageTouched(sender: UIButton!) {
        print("button connect touched");
    }

}