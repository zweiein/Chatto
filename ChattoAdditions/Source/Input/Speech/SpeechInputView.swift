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
    fileprivate var displayTextLabel: UILabel!

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
        
        //// label
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor(white: 0.15, alpha: 1.0)
        label.text = "Just a custom label. haha"
        self.displayTextLabel = label
        self.uiView.addSubview(label)
        
        //// button
        let width = self.uiView.frame.midX + 100  // self.uiView.frame.size.width / 2
        let height = self.uiView.frame.midY + 100  // self.uiView.frame.size.height / 2
        print("[Button] w=\(width), h=\(height)")
        var printMessageButton: UIButton! = {
//            let button = UIButton(type: .custom)
            let button = UIButton(frame: CGRect(x: width, y: height, width:120, height:40))
            button.isUserInteractionEnabled = true
            
            button.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
            button.addTarget(self, action: #selector(ButtonPrintMessageTouched(_:)), for: .touchUpInside)
            button.setTitle("Record", for: .normal)
            return button
        }()
        
        print(printMessageButton)
        self.addSubview(printMessageButton)
    }

    private func configureUIView() {
        self.uiView = UIView(frame: CGRect.zero)
        self.uiView.isUserInteractionEnabled = true
        self.addSubview(self.uiView)
    }

    @objc private func ButtonPrintMessageTouched(_ sender: Any) {
//    @objc func ButtonPrintMessageTouched() {
        self.displayTextLabel.text = "Button <PrintMessage> have been touched"
        print("Button <PrintMessage> have been touched");
    }

}
