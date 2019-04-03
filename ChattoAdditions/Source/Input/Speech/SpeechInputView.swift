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
    @IBOutlet weak var displayTextLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!

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
        label.text = "Click to Record"
        self.displayTextLabel = label
        self.addSubview(label)
        
        //// button
        let width = self.frame.midX + 150 // self.uiView.frame.midX + 100
        let height = self.frame.midY + 150 // self.uiView.frame.midY + 100

//        print("[Button] w=\(width), h=\(height)")
//        print("[Button] w=\(self.frame.width), h=\(self.frame.height)")
//        print("\(self.center.x), \(self.center.y)")
//        print("\(self.uiView.center.x), \(self.uiView.center.y)")
        let printMessageButton: UIButton! = {
            let button = UIButton(frame: CGRect(x: width, y: height, width:120, height:40))
//            let button = UIButton(frame: CGRect(x: self.center.x, y: self.center.y, width:120, height:40))
            button.isUserInteractionEnabled = true
//            button.center = self.center
            button.setImage(UIImage(named: "Record"), for: UIControl.State.normal)
//            button.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
//            button.addTarget(self, action: #selector(ButtonPrintMessageTouched(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonPrintMessageTouched), for: .touchUpInside)
//            button.setTitle("██", for: .normal)
            
//            let buttonBackgroundImage = UIImage(named: "Record")
//            let buttonBackgroundImageView = UIImageView(image: buttonBackgroundImage)
//            buttonBackgroundImageView.frame = CGRect(x: width, y: height, width: 40, height: 40)
//            button.addSubview(buttonBackgroundImageView)
            
            return button
        }()
        
        print(printMessageButton)
        print("[Anchor] centerX=\(self.centerXAnchor), centerY=\(self.centerYAnchor.hashValue)")
        print("[Anchor] left=\(self.leftAnchor.hashValue), right=\(self.rightAnchor.hashValue)")
        print("[Anchor] top=\(self.topAnchor.hashValue), bottom=\(self.bottomAnchor.hashValue)")
        self.recordButton = printMessageButton
        self.addSubview(printMessageButton)
//        self.addConstraints(addButtonConstraints())
//        NSLayoutConstraint.activate(addButtonConstraints())
    }

    private func configureUIView() {
        self.uiView = UIView(frame: CGRect.zero)
        self.uiView.isUserInteractionEnabled = true
        self.addSubview(self.uiView)
    }

//    @objc private func ButtonPrintMessageTouched(_ sender: Any) {
    @IBAction private func ButtonPrintMessageTouched(_ sender: Any, forEvent event: UIEvent) {
        if self.displayTextLabel.text == "Click to Record" {
            self.displayTextLabel.text = "Recording..."
            print("start to record");
            self.recordButton.backgroundColor = UIColor(red: 192, green: 0, blue: 0, alpha: 1.0)
            self.recordButton.setTitle("。。。", for: .normal)
        }
        else {
            self.displayTextLabel.text = "Click to Record"
            print("stop recording");
//            self.recordButton.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
//            self.recordButton.setTitle("██", for: .normal)
            self.recordButton.setImage(UIImage(named: "Record"), for: .normal)
        }
    }

    private func endRecording(_ sender: Any) {
        self.displayTextLabel.text = "Click to Record"
        self.recordButton.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
        self.recordButton.setTitle("Click to Record", for: .normal)
    }
    
//    private func addButtonConstraints() -> [NSLayoutConstraint] {
//        let centerX = NSLayoutConstraint.init(item: self.recordButton, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.uiView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
//
//        let centerY = NSLayoutConstraint.init(item: self.recordButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.uiView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
//
//        centerX.isActive = true
//        centerY.isActive = true
//        print("[Constraint] centerX=\(NSLayoutConstraint.Attribute.centerX.rawValue), centerY=\(NSLayoutConstraint.Attribute.centerY.rawValue)")
//        return [centerX, centerY]
//    }
}
