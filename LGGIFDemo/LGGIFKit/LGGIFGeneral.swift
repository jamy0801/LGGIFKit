//
//  LGGIFGeneral.swift
//  LGGIFDemo
//
//  Created by gujianming on 16/2/2.
//  Copyright © 2016年 jamy. All rights reserved.
//

import UIKit
import CoreGraphics
import ImageIO
import Foundation
import AVFoundation
import MobileCoreServices

public enum LGGIFSize: Int {
    case VeryLow = 2, Low = 3, Medium = 5, High = 7, Original = 10
}

public struct LGGIFGeneral {
    
    static let framePerSecond: Float = 1 / 10
    
    public static func generalGIFFromUrl(videoUrl: NSURL, loopCount: Int = 0, FPS: Int = 30, complection: ((NSURL) -> Void )?) {
        let asset = AVURLAsset(URL: videoUrl)
        let videoWidth = asset.tracksWithMediaType(AVMediaTypeVideo)[0].naturalSize.width
        let videoHeight = asset.tracksWithMediaType(AVMediaTypeVideo)[0].naturalSize.height
        let optimalSize = getOptimalSize(videoWidth, videoHeight: videoHeight)
        let videoLength = CMTimeGetSeconds(asset.duration)
        
        var timePoints = [CMTime]()
        var time: Float = 0
        var times = [NSNumber]()
        while time < Float(videoLength) {
            times.append(NSNumber(float: time))
            time += framePerSecond
        }
        
        for number in times {
            let timeValue = number.floatValue
            if timeValue < 0 || timeValue > Float(CMTimeGetSeconds(asset.duration)) {
                continue
            }
            timePoints.append(CMTimeMakeWithSeconds(Float64(timeValue), Int32(times.count)))
        }
        
        var resultUrl: NSURL!
        let path = NSTemporaryDirectory() + "test1.gif"
        let groupQueue = dispatch_group_create()
        dispatch_group_enter(groupQueue)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let result = generalGIF(asset, timePoints: timePoints, savePath: path, gifSize: optimalSize, FPS: FPS, loopCount: loopCount)
            resultUrl = result.url
            dispatch_group_leave(groupQueue)
        }
        
        dispatch_group_notify(groupQueue, dispatch_get_main_queue()) { () -> Void in
            if let complecte = complection {
                complecte(resultUrl)
                NSLog("general GIF successful--%@", resultUrl)
            }
        }
    }
    
    private static func getOptimalSize(videoWidth: CGFloat, videoHeight: CGFloat) -> LGGIFSize {
        var optimalSize = LGGIFSize.Medium
        if (videoWidth >= 1200 || videoHeight >= 1200) {
            optimalSize = .VeryLow
        }
        else if (videoWidth >= 800 || videoHeight >= 800){
            optimalSize = .Low
        }
        else if (videoWidth >= 400 || videoHeight >= 400) {
            optimalSize = .Medium
        }
        else if (videoWidth < 400 || videoHeight < 400) {
            optimalSize = .High
        }
        return optimalSize
    }
    
    private static func generalGIF(asset: AVAsset, timePoints: [CMTime], savePath: String, gifSize: LGGIFSize, FPS: Int = 30, loopCount: Int = 0) -> (finish: Bool, url: NSURL) {
        let loopCountDict = loopCountProperty(loopCount)
        let delayTimeDict = delayTimeProperty(NSNumber(float: Float(1 / FPS)))
        
        if NSFileManager.defaultManager().fileExistsAtPath(savePath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(savePath)
            } catch let error as NSError {
                NSLog("remove old filepath error:%@", error)
            }
        } else {
            NSFileManager.defaultManager().createFileAtPath(savePath, contents: nil, attributes: nil)
        }
        
        let fileUrl = NSURL(fileURLWithPath: savePath)
        if let destination = CGImageDestinationCreateWithURL(fileUrl, kUTTypeGIF, timePoints.count, nil) {
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceAfter = kCMTimeZero
            generator.requestedTimeToleranceBefore = kCMTimeZero
            
            for time in timePoints {
                do {
                    let image = try generator.copyCGImageAtTime(time, actualTime: nil)
                    CGImageDestinationAddImage(destination, image, delayTimeDict)
                } catch let error as NSError {
                    NSLog("%@",error)
                }
            }
            
            CGImageDestinationSetProperties(destination, loopCountDict)
            let finished = CGImageDestinationFinalize(destination)
            return (finished, fileUrl)
        }
        return (false, fileUrl)
    }
    
    private static func loopCountProperty(loopCount: NSNumber) -> NSDictionary {
        let dict = NSDictionary(object: loopCount, forKey: String(kCGImagePropertyGIFLoopCount))
        let gifDict = NSDictionary(object: dict, forKey: String(kCGImagePropertyGIFDictionary))
        return gifDict
    }
    
    private static func delayTimeProperty(delayTime: NSNumber) -> NSDictionary {
        let dict = NSDictionary(object: delayTime, forKey: String(kCGImagePropertyGIFDelayTime))
        let gifDict = NSDictionary(object: dict, forKey: String(kCGImagePropertyGIFDictionary))
        return gifDict
    }
}
