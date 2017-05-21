//
//  TLHoopButton.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

let MaxDragOffset:CGFloat = 300;

enum StoryType {
    case video
    case photo
}

protocol TLHoopButtonProtocol : NSObjectProtocol {
    func hoopStart(hoopButton:TLHoopButton) -> Void
    func hoopComplete(hoopButton:TLHoopButton, type:StoryType) -> Void
    func hoopDrag(hoopButton:TLHoopButton,offsetY:CGFloat) -> Void
}

class TLHoopButton: UIControl {
    public weak var delegete : TLHoopButtonProtocol?
    
    var centerPoint:CGPoint {
        return CGPoint.init(x: self.frame.width / 2.0, y: self.frame.width / 2.0)
    }
    
    fileprivate lazy var blureBgView:UIVisualEffectView = {
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        return $0
    }(UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light)))
    
    fileprivate lazy var circleView:UIView = {
        $0.backgroundColor = UIColor.white
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 27.5
        return $0
    }(UIView.init())
    
    fileprivate lazy var proLayer:CAShapeLayer = {
        var proLayer = CAShapeLayer()
        proLayer.lineWidth = 2
        proLayer.strokeColor = UIColor.init(colorHex: 0x0056ff).cgColor
        proLayer.fillColor = UIColor.clear.cgColor
        proLayer.lineJoin = kCALineJoinRound
        proLayer.lineCap = kCALineCapRound
        return proLayer
    }()
    
    fileprivate lazy var gradientLayer:CAGradientLayer = {
        var gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.init(colorHex: 0x0056ff).cgColor, UIColor.init(colorHex: 0x0056ff).cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    var timer:CADisplayLink?
    
    var percent:CGFloat = 0
    var totalPercent = CGFloat(Double.pi * 2.0) / CGFloat(TLStoryConfiguration.maxRecordingTime)
    var progress:CGFloat = 0
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        blureBgView.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        blureBgView.center = centerPoint
        self.addSubview(blureBgView)
        
        circleView.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        circleView.clipsToBounds = true
        circleView.center = centerPoint
        self.addSubview(circleView)
        
        self.layer.addSublayer(gradientLayer)
        gradientLayer.mask = proLayer
        
        self.addTarget(self, action: #selector(startAction), for: .touchDown)
        self.addTarget(self, action: #selector(complete), for: [.touchUpOutside,.touchCancel,.touchUpInside])
        self.addTarget(self, action: #selector(draggedAction), for: .touchDragInside)
        self.addTarget(self, action: #selector(draggedAction), for: .touchDragOutside)
    }
    
    @objc fileprivate func startAction(sender:UIButton) {
        self.bounds = CGRect.init(x: 0, y: 0, width: 120, height: 120)
        self.center = CGPoint.init(x: (superview?.width ?? 0) / 2, y: (superview?.bounds.height ?? 0) - 30 - 60)
        self.circleView.center = centerPoint
        self.zoom(from: 80, to: 120, view:blureBgView)
        self.gradientLayer.bounds = self.bounds;
        self.gradientLayer.position = CGPoint.init(x: self.width / 2, y: self.height / 2)
        timer?.invalidate()
        timer = CADisplayLink.init(target: self, selector: #selector(countDownd))
        timer?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        if let delegate = delegete {
            delegate.hoopStart(hoopButton: self)
        }
    }
    
    func complete() {
        timer?.invalidate()
        timer = nil
        
        if let delegate = delegete {
            delegate.hoopComplete(hoopButton: self, type: progress < 30 ? .photo : .video)
        }
        percent = 0
        progress = 0
        self.setNeedsDisplay()
        self.isHidden = true
    }
    
    func draggedAction(sender:UIButton, event:UIEvent) {
        let touch = (event.allTouches! as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self)
        let offsetY = point.y < 0 ? -point.y : 0;
        if offsetY < MaxDragOffset && offsetY > 0 {
            if let delegate = self.delegete {
                delegate.hoopDrag(hoopButton: self, offsetY: offsetY)
            }
        }
    }
    
    func reset() {
        self.bounds = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        self.center = CGPoint.init(x: (superview?.width ?? 0) / 2, y: (superview?.bounds.height ?? 0) - 53 - 40)
        self.circleView.center = centerPoint
        self.zoom(from: 122, to: 80, view:blureBgView)
        self.blureBgView.isHidden = false
        self.isHidden = false
    }
    
    @objc fileprivate func countDownd() {
        progress += 1
        percent = totalPercent * progress
        
        if progress > CGFloat(TLStoryConfiguration.maxRecordingTime) {
            self.complete()
        }
        self.setNeedsDisplay()
    }
    
    fileprivate func zoom(from:CGFloat, to:CGFloat, view:UIView) {
        view.bounds = CGRect.init(x: 0, y: 0, width: to, height: to)
        view.center = centerPoint
        view.layer.cornerRadius = to / 2.0

        let anmian = CABasicAnimation.init(keyPath: "bounds")
        anmian.fromValue = CGRect.init(x: 0, y: 0, width: from, height: from)
        anmian.toValue = CGRect.init(x: 0, y: 0, width: to, height: to)
        
        let cornerAnmian = CABasicAnimation.init(keyPath: "cornerRadius")
        cornerAnmian.fromValue = from / 2.0
        cornerAnmian.toValue = to / 2.0
        
        let combine = CAAnimationGroup.init()
        combine.isRemovedOnCompletion = false
        combine.duration = 0.25
        combine.animations = [anmian,cornerAnmian]
        view.layer.add(combine, forKey: nil)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: self.width / 2.0, y: self.height / 2.0), radius: blureBgView.layer.cornerRadius - 1, startAngle:  1.5 * CGFloat(Double.pi), endAngle: 1.5 * CGFloat(Double.pi) + percent, clockwise: true)
        self.proLayer.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
