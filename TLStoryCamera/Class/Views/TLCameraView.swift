//
//  TLCameraView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage

class TLCameraView: GPUImageView {
    fileprivate var videoCamera = GPUImageStillCamera.init(sessionPreset: AVCaptureSessionPreset1280x720, cameraPosition: .back)
    fileprivate var filterView:GPUImageView?
    fileprivate var beautifyFilter = TLStoryConfiguration.openBeauty ? GPUImageBeautifyFilter.init() : GPUImageFilter.init()
    fileprivate var movieWriter:GPUImageMovieWriter?
    fileprivate var currentVideoPath:URL?
    fileprivate var currentPhotoPath:URL?
    
    fileprivate var focusAnim:CAAnimationGroup = {
        let zoomAnim = CABasicAnimation.init(keyPath: "transform.scale")
        zoomAnim.fromValue = 1.5
        zoomAnim.toValue = 1
        zoomAnim.byValue = 0.8
        
        let alphaAnim = CABasicAnimation.init(keyPath: "opacity")
        alphaAnim.fromValue = 1
        alphaAnim.toValue = 0
        
        let group = CAAnimationGroup.init()
        group.animations = [zoomAnim,alphaAnim]
        group.duration = 0.3 
        group.isRemovedOnCompletion = true
        return group
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        videoCamera?.outputImageOrientation = .portrait
        videoCamera?.horizontallyMirrorFrontFacingCamera = true
        videoCamera?.removeAllTargets()
        videoCamera!.addTarget(beautifyFilter as! GPUImageInput)
        beautifyFilter.addTarget(self)
    }
    
    public func cameraSwitch(open:Bool) {
        open ? videoCamera?.startCapture() : videoCamera?.stopCapture()
    }
    
    public func cameraZoom(offseY:CGFloat) {
        let maxZoomFactor = videoCamera?.inputCamera.activeFormat.videoMaxZoomFactor ?? 1
        let max = maxZoomFactor > TLStoryConfiguration.maxVideoZoomFactor ? TLStoryConfiguration.maxVideoZoomFactor : maxZoomFactor
        let per = MaxDragOffset / max
        let zoom = offseY / per
        do {
            try videoCamera?.inputCamera.lockForConfiguration()
            videoCamera?.inputCamera.videoZoomFactor = zoom + 1.0
            videoCamera?.inputCamera.unlockForConfiguration()
        } catch {
            
        }
    }
    
    public func startCapture() {
        videoCamera?.startCapture()
    }
    
    public func stopCapture() {
        videoCamera?.stopCapture()
    }

    public func startRecording() {
        movieWriter?.startRecording()
    }
    
    public func initRecording() {
        currentVideoPath = getVideoFilePath()
        movieWriter = GPUImageMovieWriter.init(movieURL: self.currentVideoPath, size: CGSize.init(width: 720, height: 1280), fileType: AVFileTypeMPEG4, outputSettings: TLStoryConfiguration.videoSetting)
        movieWriter?.setHasAudioTrack(true, audioSettings: TLStoryConfiguration.audioSetting)
        beautifyFilter.addTarget(self.movieWriter!)
        videoCamera?.audioEncodingTarget = movieWriter
        movieWriter?.encodingLiveVideo = true
    }
    
    public func rotateCamera() {
        videoCamera?.rotateCamera()
    }
    
    public func resumeCamera() {
        if let vPath = currentVideoPath {
            do {
                try FileManager.default.removeItem(at: vPath)
                currentVideoPath = nil
            } catch {
                print("video delete failure")
            }
        }
        if let pPath = currentPhotoPath {
            do {
                try FileManager.default.removeItem(at: pPath)
                currentPhotoPath = nil
            } catch {
                print("photo delete failure")
            }
        }
        
        videoCamera?.resumeCameraCapture()
    }
    
    public func finishRecording(complete:@escaping ((URL) -> Void)) {
        movieWriter?.finishRecording(completionHandler: { [weak self] in
            DispatchQueue.main.async {
                self?.beautifyFilter.removeTarget(self?.movieWriter!)
                self?.videoCamera?.pauseCapture()
                if let path = self?.currentVideoPath {
                    complete(path)
                }
            }
        })
    }
    
    public func capturePhoto(complete:@escaping ((URL?) -> Void)){
        videoCamera?.capturePhotoAsImageProcessedUp(toFilter: beautifyFilter, with: .up, withCompletionHandler: { [weak self] (image, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.beautifyFilter.removeTarget(self?.movieWriter!)
            strongSelf.videoCamera?.pauseCapture()
            guard let img = image else {
                complete(nil)
                return
            }
            let imgData = UIImagePNGRepresentation(img)
            strongSelf.currentPhotoPath = strongSelf.getPhotoFilePath()
            do {
                try imgData?.write(to: strongSelf.currentPhotoPath!)
                complete(strongSelf.currentPhotoPath!)
            }catch {
                complete(nil)
            }
        })
    }
    
    public func flashStatusChange() -> AVCaptureTorchMode {
        if !videoCamera!.inputCamera.hasFlash || !videoCamera!.inputCamera.hasTorch {
            return .auto
        }
        
        let rawValue = videoCamera!.inputCamera.torchMode.rawValue + 1
        let mode = AVCaptureTorchMode(rawValue: rawValue + 1 > 3 ? 0 : rawValue)!
        do {
            try videoCamera?.inputCamera.lockForConfiguration()
            videoCamera?.inputCamera.torchMode = mode
            videoCamera?.inputCamera.unlockForConfiguration()
        } catch {
            
        }
        return mode
    }
    
    fileprivate func getVideoFilePath() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyvideo")
        let filePath = path?.appending("/\(Int(Date().timeIntervalSince1970)).mp4")
        do {
            try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        return URL.init(fileURLWithPath: filePath!)
    }
    
    fileprivate func getPhotoFilePath() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/storyphoto")
        let filePath = path?.appending("/\(Int(Date().timeIntervalSince1970)).png")
        do {
            try FileManager.default.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            
        }
        return URL.init(fileURLWithPath: filePath!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self)
        
        if !videoCamera!.inputCamera.isFocusModeSupported(.autoFocus) || !videoCamera!.inputCamera.isFocusPointOfInterestSupported {
            return
        }
        
        do {
            try videoCamera?.inputCamera.lockForConfiguration()
            videoCamera!.inputCamera.focusMode = .autoFocus
            videoCamera!.inputCamera.focusPointOfInterest = point
            videoCamera!.inputCamera.unlockForConfiguration()
        } catch {
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
