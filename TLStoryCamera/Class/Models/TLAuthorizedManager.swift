//
//  TLAuthorizedManager.swift
//  TLStoryCamera
//
//  Created by garry on 2017/5/26.
//  Copyright © 2017年 com.garry. All rights reserved.
//

import UIKit
import Photos

protocol TLAuthorizedManagerDelegate: NSObjectProtocol {
    func authorization(type:TLAuthorizedManager.AuthorizedType, authorized:Bool)
}

class TLAuthorizedManager: NSObject {
    public weak var delegate:TLAuthorizedManagerDelegate?
    
    public enum AuthorizedType {
        case mic
        case camera
        case album
    }
    
    public func requestAuthorization(with type:AuthorizedType) {
        if type == .mic {
            self.requestMicAuthorizationStatus()
        }
        if type == .camera {
            self.requestCameraAuthorizationStatus()
        }
        if type == .album {
            self.requestAlbumAuthorizationStatus()
        }
    }
    
    public func checkAuthorization(with type:AuthorizedType) -> Bool {
        if type == .mic {
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) == .authorized
        }
        if type == .camera {
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
        }
        if type == .album {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        return false
    }
    
    fileprivate func requestMicAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if status == .authorized {
            self.callDelegate(with: .mic, authorized: true)
        }else if status == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in
                self.callDelegate(with: .mic, authorized: granted)
            })
        }else if (status == .denied) {
            UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate func requestCameraAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == .authorized {
            self.callDelegate(with: .camera, authorized: true)
        }else if status == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                self.callDelegate(with: .camera, authorized: granted)
            })
        }else if (status == .denied) {
            UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate func requestAlbumAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            self.callDelegate(with: .album, authorized: true)
        }else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (s) in
                if s == .authorized {
                    self.callDelegate(with: .album, authorized: true)
                }else {
                    self.callDelegate(with: .album, authorized: false)
                }
            })
        }else if status == .denied {
            UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
    
    func callDelegate(with type:AuthorizedType, authorized:Bool) {
        DispatchQueue.main.async {
            self.delegate?.authorization(type: type, authorized: authorized)
        }
    }
}
