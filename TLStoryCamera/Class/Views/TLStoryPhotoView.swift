//
//  TLStoryPhotoView.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit
import GPUImage
import Photos
import SVProgressHUD

class TLStoryPhotoView: TLStoryPreviewView {
    fileprivate var imgView:UIImageView = {
        let imgView = UIImageView.init()
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    fileprivate var sourceImg:UIImage?
    
    init(frame: CGRect, url:URL) {
        super.init(frame: frame)
        
        self.insertSubview(imgView, at: 0)
        imgView.frame = self.bounds
        
        if let d = try? Data.init(contentsOf: url) {
            sourceImg = UIImage.init(data: d)
            imgView.image = sourceImg
        }
    }
    
    init(frame: CGRect, imgData:Data) {
        super.init(frame: frame)
        
        self.insertSubview(imgView, at: 0)
        imgView.frame = self.bounds
        
        sourceImg = UIImage.init(data: imgData)
        imgView.image = sourceImg
    }
    
    override func saveAction() {
        self.handlePhoto()
    }
    
    override func hideAllIcons() {
        UIView.animate(withDuration: 0.15) {
            self.drawBtn.alpha = 0
            self.closeBtn.alpha = 0
            self.tagsBtn.alpha = 0
            self.textBtn.alpha = 0
            self.saveBtn.alpha = 0
        }
    }
    
    override func showAllIcons() {
        UIView.animate(withDuration: 0.15) {
            self.drawBtn.alpha = 1
            self.closeBtn.alpha = 1
            self.tagsBtn.alpha = 1
            self.textBtn.alpha = 1
            self.saveBtn.alpha = 1
        }
    }
    
    fileprivate func handlePhoto() {
        guard let img = getEditImg() else {
            return
        }
        
        SVProgressHUD.show()
        DispatchQueue.global().async {
            let resultImg = self.sourceImg?.imageMontage(img: img)
            let imgData = UIImagePNGRepresentation(resultImg!)
            
            let filePath = TLStoryConfiguration.photoPath?.appending("/\(Int(Date().timeIntervalSince1970))_temp.png")
            
            if let p = filePath {
                let u = URL.init(fileURLWithPath: p)
                do {
                    try imgData?.write(to: u)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: u)
                    }, completionHandler: { (x, e) in
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            SVProgressHUD.showSuccess(withStatus: "已保存到相册")
                            self.closeAction()
                            self.delegate?.storyPreviewClose()
                        }
                    })
                } catch {
                    
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
