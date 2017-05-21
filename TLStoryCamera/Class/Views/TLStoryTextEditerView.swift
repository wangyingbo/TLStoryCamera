//
//  TLStoryTextEditerView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

protocol TLStoryTextEditerDelegate: NSObjectProtocol {
    func textEditerDidCompleteEdited(sticker:TLStickerTextView, isNew:Bool)
    func textEditerKeyboard(hidden:Bool, offsetY: CGFloat)
}

class TLStoryTextEditerView: UIView {
    fileprivate var inputTextView:UITextView = {
        let textView = UITextView.init()
        textView.backgroundColor = UIColor.clear
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.font = UIFont.boldSystemFont(ofSize: TLStoryConfiguration.defaultTextWeight)
        return textView
    }()
    
    fileprivate var editingSticker: TLStickerTextView?
    
    public weak var delegate:TLStoryTextEditerDelegate?
    
    fileprivate var textToolsBar:TLStoryTextInputToolsBar?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(colorHex: 0x000000, alpha: 0.5)
        self.isHidden = true
        
        inputTextView.delegate = self
        
        textToolsBar = TLStoryTextInputToolsBar.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: 55))
        textToolsBar!.delegate = self
        self.addSubview(textToolsBar!)
        
        self.addSubview(inputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(sticker:TLStickerTextView?) {
        self.isHidden = false
        
        if let s = sticker {
            editingSticker = s
            inputTextView.text = s.text
            inputTextView.font = s.font
            inputTextView.textColor = s.textColor
            inputTextView.textAlignment = s.textAlignment
            let size = inputTextView.sizeThatFits(CGSize.init(width: inputTextView.width, height: CGFloat(MAXFLOAT)))
            inputTextView.bounds = CGRect.init(x: 0, y: 0, width: inputTextView.width, height: size.height)
        }else {
            inputTextView.bounds = CGRect.init(x: 0, y: 0, width: self.width - 20, height: TLStoryConfiguration.defaultTextWeight + 20)
            inputTextView.text = ""
            inputTextView.font = UIFont.boldSystemFont(ofSize: TLStoryConfiguration.defaultTextWeight)
            inputTextView.textAlignment = .center
            inputTextView.textColor = UIColor.white
        }
        
        inputTextView.becomeFirstResponder()
    }
    
    func keyboardWillShow(sender:NSNotification) {
        guard let frame = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        
        if editingSticker != nil {
            let toPoint = CGPoint.init(x: self.width / 2, y: (self.height - frame.height) / 2)
            self.inputTextView.center = toPoint
            self.showAnim(to: toPoint)
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.inputTextView.center = CGPoint.init(x: self.width / 2, y: (self.height - frame.height) / 2)
            })
        }
        
        self.delegate?.textEditerKeyboard(hidden: false, offsetY: frame.height)
    }
    
    func keyboardWillHide() {
        if editingSticker != nil {
            self.hideAnim()
        }else {
            self.isHidden = true
        }
        
        self.delegate?.textEditerKeyboard(hidden: true, offsetY: 0)
    }
    
    func showAnim(to point:CGPoint) {
        let radians = atan2f(Float(self.editingSticker!.transform.b), Float(self.editingSticker!.transform.a))

        let positionAnim = CABasicAnimation.init(keyPath: "position")
        positionAnim.fromValue = editingSticker!.center
        positionAnim.toValue = point
        
        let rotationAnim = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = radians
        rotationAnim.toValue = 0
        
        let groupAnim = CAAnimationGroup.init()
        groupAnim.animations = [positionAnim,rotationAnim]
        groupAnim.duration = 0.25
        groupAnim.isRemovedOnCompletion = true
        
        self.inputTextView.layer.add(groupAnim, forKey: "beginAnim")
    }
    
    func hideAnim() {
        let radians = atan2f(Float(self.editingSticker!.transform.b), Float(self.editingSticker!.transform.a))
        
        let positionAnim = CABasicAnimation.init(keyPath: "position")
        positionAnim.fromValue = self.inputTextView.center
        positionAnim.toValue = self.editingSticker!.center
        
        let rotationAnim = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnim.fromValue = 0
        rotationAnim.toValue = radians
        
        let groupAnim = CAAnimationGroup.init()
        groupAnim.animations = [positionAnim,rotationAnim]
        groupAnim.duration = 0.25
        groupAnim.fillMode = kCAFillModeForwards
        groupAnim.isRemovedOnCompletion = false
        groupAnim.delegate = self
        
        self.inputTextView.layer.add(groupAnim, forKey: "endAnim")
    }
    
    func setTextColor(color:UIColor) {
        self.inputTextView.textColor = color
    }
    
    func setTextSize(size:CGFloat) {
        self.inputTextView.font = UIFont.boldSystemFont(ofSize: size)
    }
    
    func setTextAlignment() -> NSTextAlignment {
        let r = inputTextView.textAlignment.rawValue + 1
        let textAlignment = NSTextAlignment(rawValue: r > 2 ? 0 : r)!
        inputTextView.textAlignment = textAlignment
        return textAlignment
    }
}

extension TLStoryTextEditerView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.inputTextView.center = self.editingSticker!.center
        self.inputTextView.layer.removeAllAnimations()
        self.delegate?.textEditerDidCompleteEdited(sticker: editingSticker!, isNew: false)
        self.editingSticker = nil
        self.isHidden = true
    }
}

extension TLStoryTextEditerView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if (textView.markedTextRange == nil) {
            textView.flashScrollIndicators()
            
            let size = textView.sizeThatFits(CGSize.init(width: inputTextView.width, height: CGFloat(MAXFLOAT)))
            inputTextView.bounds = CGRect.init(x: 0, y: 0, width: inputTextView.width, height: size.height)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.textInputToolsBarConfirm()
            return false
        }
        return true
    }
}

extension TLStoryTextEditerView: TLStoryTextInputToolsBarDelegate {
    func textInputToolsBarChange() -> NSTextAlignment {
        return self.setTextAlignment()
    }
    
    func textInputToolsBarConfirm() {
        if let s = editingSticker {
            s.font = inputTextView.font
            s.text = inputTextView.text
            s.textColor = inputTextView.textColor
            s.textAlignment = inputTextView.textAlignment
        }else {
            let sticker = TLStickerTextView.init(frame: self.inputTextView.bounds)
            sticker.center = inputTextView.center
            sticker.font = inputTextView.font
            sticker.text = inputTextView.text
            sticker.textColor = inputTextView.textColor
            sticker.textAlignment = inputTextView.textAlignment
            self.delegate?.textEditerDidCompleteEdited(sticker: sticker, isNew: true)
        }
        
        inputTextView.resignFirstResponder()
    }
}



protocol TLStoryTextInputToolsBarDelegate:NSObjectProtocol {
    func textInputToolsBarChange() -> NSTextAlignment
    func textInputToolsBarConfirm()
}

class TLStoryTextInputToolsBar: UIView {
    fileprivate var textAlignmentBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_align_center"), for: .normal)
        btn.addTarget(self, action: #selector(textAlignmentAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate var confrimBtn: UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.setTitle("确定", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(confrimAction), for: .touchUpInside)
        return btn
    }()
    
    public weak var delegate:TLStoryTextInputToolsBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(textAlignmentBtn)
        textAlignmentBtn.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        textAlignmentBtn.center = CGPoint.init(x: textAlignmentBtn.width / 2, y: textAlignmentBtn.height / 2)
        
        self.addSubview(confrimBtn)
        confrimBtn.bounds = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        confrimBtn.center = CGPoint.init(x: self.width - confrimBtn.width / 2, y:confrimBtn.height / 2)
        
        let textAlignmentTap = UITapGestureRecognizer.init(target: self, action: #selector(textAlignmentAction))
        textAlignmentBtn.addGestureRecognizer(textAlignmentTap)
        
        let confrimTap = UITapGestureRecognizer.init(target: self, action: #selector(confrimAction))
        confrimBtn.addGestureRecognizer(confrimTap)
    }
    
    public func textAlignmentAction(sender:UITapGestureRecognizer) {
        let v = sender.view as! UIButton
        let imgs = [NSTextAlignment.left:#imageLiteral(resourceName: "story_publish_icon_align_left"),
                    NSTextAlignment.center:#imageLiteral(resourceName: "story_publish_icon_align_center"),
                    NSTextAlignment.right:#imageLiteral(resourceName: "story_publish_icon_align_right")]
        let textAlignment = self.delegate?.textInputToolsBarChange()
        print(textAlignment!)
        v.setImage(imgs[textAlignment!], for: .normal)
    }
    
    public func confrimAction() {
        self.delegate?.textInputToolsBarConfirm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
