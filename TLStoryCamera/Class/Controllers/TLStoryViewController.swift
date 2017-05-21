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
    fileprivate lazy var flashBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_flashlight_auto"), for: .normal)
        btn.addTarget(self, action: #selector(flashAction), for: .touchUpInside)
        return btn
    }()
    
    fileprivate lazy var switchBtn:UIButton = {
        let btn = UIButton.init(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "story_publish_icon_cam_turn"), for: .normal)
        btn.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
        return btn
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        cameraView = TLCameraView.init(frame: self.view.bounds)
        view.addSubview(cameraView!)
        cameraView?.initRecording()
        cameraView?.startCapture()
        
        startBtn.center = CGPoint.init(x: view.center.x, y: view.bounds.height - 52 - 40)
        startBtn.delegete = self
        view.addSubview(startBtn)
        
        flashBtn.sizeToFit()
        flashBtn.center = CGPoint.init(x: startBtn.centerX - 100, y: startBtn.centerY)
        view.addSubview(flashBtn)
        
        switchBtn.sizeToFit()
        switchBtn.center = CGPoint.init(x: startBtn.centerX + 100, y: startBtn.centerY)
        view.addSubview(switchBtn)
    }
    
   @objc fileprivate func flashAction(sender: UIButton) {
        let mode = self.cameraView!.flashStatusChange()
        let imgs = [AVCaptureTorchMode.on:#imageLiteral(resourceName: "story_publish_icon_flashlight_on"),
                    AVCaptureTorchMode.off:#imageLiteral(resourceName: "story_publish_icon_flashlight_off"),
                    AVCaptureTorchMode.auto:#imageLiteral(resourceName: "story_publish_icon_flashlight_auto")]
        sender.setImage(imgs[mode], for: .normal)
    }
    
    func switchAction(sender: UIButton) {
        cameraView?.rotateCamera()
    }
    
    func showPreview(type:StoryType, url:URL?) -> Void {
        guard let u = url else {
            return
        }
        
        if type == .photo {
            let photoView = TLStoryPhotoView.init(frame: view.bounds, url: u)
            photoView.delegate = self
            self.view.addSubview(photoView)
        }else {
            let videoView = TLStoryPlayerView.init(frame: view.bounds, url: u)
            videoView.delegate = self
            self.view.addSubview(videoView)
        }
    }
    override public var prefersStatusBarHidden: Bool {
        return true
    }
}

extension TLStoryViewController : TLHoopButtonProtocol {
    func hoopStart(hoopButton: TLHoopButton) {
        cameraView?.initRecording()
        cameraView?.startRecording()
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
        self.startBtn.reset()
        UIView.animate(withDuration: 0.25) {
            self.flashBtn.alpha = 1
            self.switchBtn.alpha = 1
        }
    }
}
