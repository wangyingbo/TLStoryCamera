//
//  TLStoryCameraViewController.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

public class TLStoryViewController: UIViewController {
    fileprivate var cameraView:TLCameraView?
    fileprivate lazy var startBtn = TLHoopButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
    fileprivate lazy var flashBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_flashlight_auto"), for: .normal)
        btn.addTarget(self, action: #selector(flashAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var switchBtn:TLButton = {
        let btn = TLButton.init(type: UIButtonType.custom)
        btn.showsTouchWhenHighlighted = true
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_cam_turn"), for: .normal)
        btn.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate var photoLibraryHintView:TLPhotoLibraryHintView?
    
    fileprivate var photoLibraryPicker:TLPhotoLibraryPickerView?
    
    fileprivate var swipeUp:UISwipeGestureRecognizer?
    
    fileprivate var swipeDown:UISwipeGestureRecognizer?
    
    fileprivate var coverBlurView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    
    public override func loadView() {
        self.view = TLStoryBgView.init(frame: UIScreen.main.bounds)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.isUserInteractionEnabled = true
        
        cameraView = TLCameraView.init(frame: self.view.bounds)
        view.addSubview(cameraView!)
        cameraView!.initRecording()
        cameraView!.startCapture()
        
        startBtn.center = CGPoint.init(x: view.center.x, y: view.bounds.height - 52 - 40)
        startBtn.delegete = self
        view.addSubview(startBtn)
        
        flashBtn.sizeToFit()
        flashBtn.center = CGPoint.init(x: startBtn.centerX - 100, y: startBtn.centerY)
        view.addSubview(flashBtn)
        
        switchBtn.sizeToFit()
        switchBtn.center = CGPoint.init(x: startBtn.centerX + 100, y: startBtn.centerY)
        view.addSubview(switchBtn)
        
        photoLibraryHintView = TLPhotoLibraryHintView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        photoLibraryHintView?.center = CGPoint.init(x: self.view.width / 2, y: self.view.height - 25)
        view.addSubview(photoLibraryHintView!)
        
        photoLibraryPicker = TLPhotoLibraryPickerView.init(frame: CGRect.init(x: 0, y: self.view.height, width: self.view.width, height: 165))
        photoLibraryPicker?.delegate = self
        view.addSubview(photoLibraryPicker!)
        
        self.view.addSubview(coverBlurView)
        coverBlurView.frame = self.view.bounds
        coverBlurView.isHidden = true
        coverBlurView.isUserInteractionEnabled = true
        
        swipeUp = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeAction))
        swipeUp?.direction = .up
        self.view.addGestureRecognizer(swipeUp!)
        
        swipeDown = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeAction))
        swipeDown!.direction = .down
        coverBlurView.addGestureRecognizer(swipeDown!)
    }
    
    @objc fileprivate func flashAction(sender: UIButton) {
        let mode = self.cameraView!.flashStatusChange()
        let imgs = [AVCaptureTorchMode.on:#imageLiteral(resourceName: "story_publish_icon_flashlight_on"),
                    AVCaptureTorchMode.off:#imageLiteral(resourceName: "story_publish_icon_flashlight_off"),
                    AVCaptureTorchMode.auto:#imageLiteral(resourceName: "story_publish_icon_flashlight_auto")]
        sender.setImage(imgs[mode], for: .normal)
    }
    
    @objc fileprivate func switchAction(sender: UIButton) {
        cameraView?.rotateCamera()
    }
    
    @objc fileprivate func swipeAction(sender:UISwipeGestureRecognizer) {
        self.photoLibraryPicker(hidden: sender.direction == .down)
    }
    
    fileprivate func photoLibraryPicker(hidden:Bool) {
        if hidden {
            UIView.animate(withDuration: 0.25, animations: {
                self.coverBlurView.alpha = 0
                self.view.y = 0
            }, completion: { (x) in
                self.coverBlurView.isHidden = true
            })
        }else {
            self.photoLibraryPicker?.loadPhotos()
            coverBlurView.isHidden = false
            coverBlurView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.coverBlurView.alpha = 1
                self.view.y = -165
            })
        }
    }
    
    fileprivate func showPreview(type:StoryType, url:URL?) -> Void {
        guard let u = url else {
            return
        }
        if type == .photo {
            self.showPhotoPreview(url: u)
        }else {
            self.showVideoPreview(url: u)
        }
    }
    
    fileprivate func showPhotoPreview(url:URL) {
        let photoView = TLStoryPhotoView.init(frame: view.bounds, url: url)
        photoView.delegate = self
        self.view.addSubview(photoView)
        self.cameraView?.pauseCamera()
        self.swipeUp(enable: false)
    }
    
    fileprivate func showPhotoPreview(imgData:Data) {
        let photoView = TLStoryPhotoView.init(frame: view.bounds, imgData: imgData)
        photoView.delegate = self
        self.view.addSubview(photoView)
        self.cameraView?.pauseCamera()
        self.swipeUp(enable: false)
    }
    
    fileprivate func showVideoPreview(url:URL) {
        let videoView = TLStoryPlayerView.init(frame: view.bounds, url: url)
        videoView.delegate = self
        self.view.addSubview(videoView)
        self.cameraView?.pauseCamera()
        self.swipeUp(enable: false)
    }
    
    fileprivate func swipeUp(enable:Bool) {
        if enable {
            self.view.addGestureRecognizer(swipeUp!)
        }else {
            self.view.removeGestureRecognizer(swipeUp!)
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}

extension TLStoryViewController : TLHoopButtonDelegate {
    func hoopStart(hoopButton: TLHoopButton) {
        cameraView?.initRecording()
        cameraView?.startRecording()
        photoLibraryHintView?.isHidden = true
    }
    func hoopDrag(hoopButton: TLHoopButton, offsetY: CGFloat) {
        self.cameraView?.cameraZoom(offseY: offsetY)
    }
    func hoopComplete(hoopButton: TLHoopButton, type: StoryType) {
        if type == .photo {
            self.cameraView?.capturePhoto(complete: { [weak self] (x) in
                self?.showPreview(type: .photo, url: x)
            })
        }else {
            self.cameraView?.finishRecording(complete: { [weak self] (x) in
                self?.showPreview(type: .video, url: x)
            })
        }
        
        UIView.animate(withDuration: 0.25) {
            self.flashBtn.alpha = 0
            self.switchBtn.alpha = 0
        }
    }
}

extension TLStoryViewController : TLStoryPreviewDelegate {
    func storyPreviewClose() {
        cameraView?.resumeCamera()
        UIView.animate(withDuration: 0.25) {
            self.flashBtn.alpha = 1
            self.switchBtn.alpha = 1
        }
        self.startBtn.show()
        photoLibraryHintView?.isHidden = false
        self.swipeUp(enable: true)
    }
}

extension TLStoryViewController: TLPhotoLibraryPickerViewDelegate {
    func photoLibraryPickerDidSelectPhoto(imgData: Data) {
        self.photoLibraryPicker(hidden: true)
        self.showPhotoPreview(imgData: imgData)
    }
    
    func photoLibraryPickerDidSelectVideo(url: URL) {
        self.photoLibraryPicker(hidden: true)
        self.showPreview(type: .video, url: url)
    }
}

class TLStoryBgView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if point.y < self.height + 165 {
            return true
        }
        return super.point(inside: point, with: event)
    }
}
