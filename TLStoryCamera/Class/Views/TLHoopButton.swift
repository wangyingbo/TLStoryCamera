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

protocol TLHoopButtonDelegate : NSObjectProtocol {
    func hoopStart(hoopButton:TLHoopButton) -> Void
    func hoopComplete(hoopButton:TLHoopButton, type:StoryType) -> Void
    func hoopDrag(hoopButton:TLHoopButton,offsetY:CGFloat) -> Void
}

class TLHoopButton: UIControl {
    public weak var delegete : TLHoopButtonDelegate?
    
    public var centerPoint:CGPoint {
        return CGPoint.init(x: self.width / 2.0, y: self.width / 2.0)
    }
    
    fileprivate let zoomInSize = CGSize.init(width: 120, height: 120)
    
    fileprivate let zoomOutSize = CGSize.init(width: 80, height: 80)
    
    fileprivate lazy var blureCircleView:UIVisualEffectView = {
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        return $0
    }(UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light)))
    
    fileprivate lazy var insideCircleView:UIView = {
        $0.backgroundColor = UIColor.white
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 27.5
        return $0
    }(UIView.init())
    
    fileprivate lazy var ringMaskLayer:CAShapeLayer = {
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
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    fileprivate var isBeginAnim:Bool = false
    
    fileprivate var timer:CADisplayLink?
    
    fileprivate var percent:CGFloat = 0
    
    fileprivate var totalPercent = CGFloat(Double.pi * 2.0) / CGFloat(TLStoryConfiguration.maxRecordingTime)
    
    fileprivate var progress:CGFloat = 0
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        blureCircleView.bounds = CGRect.init(x: 0, y: 0, width: zoomOutSize.width, height: zoomOutSize.height)
        blureCircleView.center = centerPoint
        self.addSubview(blureCircleView)
        
        insideCircleView.frame = CGRect.init(x: 0, y: 0, width: 55, height: 55)
        insideCircleView.clipsToBounds = true
        insideCircleView.center = centerPoint
        self.addSubview(insideCircleView)
        
        self.layer.addSublayer(gradientLayer)
        gradientLayer.mask = ringMaskLayer
        
        self.addTarget(self, action: #selector(startAction), for: .touchDown)
        self.addTarget(self, action: #selector(complete), for: [.touchUpOutside,.touchCancel,.touchUpInside])
        self.addTarget(self, action: #selector(draggedAction), for: .touchDragInside)
        self.addTarget(self, action: #selector(draggedAction), for: .touchDragOutside)
    }
    
    @objc fileprivate func startAction(sender:UIButton) {
        self.bounds = CGRect.init(x: 0, y: 0, width: zoomInSize.width, height: zoomInSize.height)
        self.center = CGPoint.init(x: superview!.width / 2, y: superview!.bounds.height - 30 - 60)
        self.insideCircleView.center = centerPoint
        self.zoom(begin: true)
        self.gradientLayer.bounds = self.bounds;
        self.gradientLayer.position = self.centerPoint
        
        timer?.invalidate()
        timer = CADisplayLink.init(target: self, selector: #selector(countDownd))
        timer?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        if let delegate = delegete {
            delegate.hoopStart(hoopButton: self)
        }
    }
    
    public func complete() {
        timer?.invalidate()
        timer = nil
        
        if let delegate = delegete {
            delegate.hoopComplete(hoopButton: self, type: progress < CGFloat(TLStoryConfiguration.minRecordingTime) ? .photo : .video)
        }
        percent = 0
        progress = 0
        self.setNeedsDisplay()
        self.isHidden = true
    }
    
    @objc fileprivate func draggedAction(sender:UIButton, event:UIEvent) {
        let touch = (event.allTouches! as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self)
        let offsetY = point.y < 0 ? -point.y : 0;
        if offsetY < MaxDragOffset && offsetY > 0 {
            delegete?.hoopDrag(hoopButton: self, offsetY: offsetY)
        }
    }
    
    public func reset() {
        self.bounds = CGRect.init(x: 0, y: 0, width: zoomOutSize.width, height: zoomOutSize.height)
        self.center = CGPoint.init(x: superview!.width / 2, y: superview!.bounds.height - 53 - 40)
        self.insideCircleView.center = centerPoint
        self.zoom(begin: false)
        blureCircleView.isHidden = false
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
    
    fileprivate func zoom(begin:Bool) {
        blureCircleView.center = centerPoint

        let anim = CABasicAnimation.init(keyPath: "transform.scale")
        anim.fromValue = begin ? 1 : 1.5
        anim.toValue = begin ? 1.5 : 1
        anim.fillMode = kCAFillModeForwards
        anim.isRemovedOnCompletion = false
        anim.duration = 0.25
        anim.delegate = self
        
        isBeginAnim = begin
        
        blureCircleView.layer.add(anim, forKey: "scale")
    }
    
    internal override func draw(_ rect: CGRect) {
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: self.width / 2.0, y: self.height / 2.0), radius: 59, startAngle:  1.5 * CGFloat(Double.pi), endAngle: 1.5 * CGFloat(Double.pi) + percent, clockwise: true)
        self.ringMaskLayer.path = path.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TLHoopButton: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag {
            return
        }
        blureCircleView.layer.removeAnimation(forKey: "anim")
        
        if isBeginAnim {
            blureCircleView.transform.scaledBy(x: 1.5, y: 1.5)
        }else {
            blureCircleView.transform.scaledBy(x: 1, y: 1)
        }
    }
}
