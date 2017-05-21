//
//  TLStoryConfiguration.swift
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/5/10.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

import UIKit

class TLStoryConfiguration: NSObject {
    public static var openBeauty:Bool = false
    public static var maxRecordingTime:TimeInterval = 10.0 * 60
    public static var maxVideoZoomFactor:CGFloat = 20
    public static let videoSetting:[String : Any] = [
        AVVideoCodecKey : AVVideoCodecH264,
        AVVideoWidthKey : 720,
        AVVideoHeightKey: 1280,
        AVVideoCompressionPropertiesKey:
            [
                AVVideoProfileLevelKey : AVVideoProfileLevelH264Main31,
                AVVideoAllowFrameReorderingKey : false,
                AVVideoAverageBitRateKey : 720 * 1280 * 3 / 2.0
        ]
    ]
    public static let audioSetting:[String : Any] = [
        AVFormatIDKey : kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 2,
        AVSampleRateKey : 16000,
        AVEncoderBitRateKey : 32000
    ]
    
    public static let maxDrawLineWeight:CGFloat = 30
    public static let minDrawLineWeight:CGFloat = 5
    public static let defaultDrawLineWeight:CGFloat = 5
    
    public static let maxTextWeight:CGFloat = 60
    public static let minTextWeight:CGFloat = 30
    public static let defaultTextWeight:CGFloat = 50
}
