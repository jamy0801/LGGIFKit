//
//  LGGIFPlayer.swift
//  LGGIFDemo
//
//  Created by gujianming on 16/2/2.
//  Copyright © 2016年 jamy. All rights reserved.
//

import UIKit
import ImageIO

public class LGGIFPlayer: UIView {
    
    var frames = [CGImageRef]()
    var delayTimes = [NSNumber]()
    var totalTimes: Float = 0
    var GifWidth: CGFloat = 0
    var GifHeight: CGFloat = 0
    var gifPlayView = UIView()
    
    convenience init?(frame: CGRect, fileUrl: NSURL) {
        self.init(frame: frame)
        let source = CGImageSourceCreateWithURL(fileUrl, nil)
        guard let source1 = source else {return nil}
        getFrameInfo(source1)
        setupGifView()
    }
    
    convenience init?(frame: CGRect, fileData: NSData) {
        self.init(frame: CGRectZero)
        let source = CGImageSourceCreateWithData(fileData, nil)
        guard let source1 = source  else {return nil}
        getFrameInfo(source1)
        setupGifView()
    }
    
    func setupGifView() {
        if GifWidth > 0 && GifHeight > 0 {
            gifPlayView.center = center
            gifPlayView.bounds = CGRectMake(0, 0, GifWidth, GifHeight)
        }
    }
    
    public func startAnimation(repeatCount: Float = 2) {
        if subviews.contains(gifPlayView) {
            gifPlayView.removeFromSuperview()
        } else {
            addSubview(gifPlayView)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "contents")
        var currentTime: Float = 0
        let count = delayTimes.count
        
        var timeValues = [NSNumber]()
        var imageValues = [CGImageRef]()
        
        for i in 0 ..< count {
            timeValues.append(NSNumber(float: currentTime / totalTimes))
            currentTime += delayTimes[i].floatValue
            imageValues.append(frames[i])
        }
        
        animation.keyTimes = timeValues
        animation.values = imageValues
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = Double(totalTimes)
        animation.delegate = self
        animation.repeatCount = repeatCount
        
        gifPlayView.layer.addAnimation(animation, forKey: "showGif")
    }
    
    public func stopAnimation() {
        gifPlayView.layer.removeAllAnimations()
    }
    
    private func getFrameInfo(source: CGImageSourceRef) {
        let frameCount = CGImageSourceGetCount(source)
        for i in 0 ..< frameCount {
            if let frame = CGImageSourceCreateImageAtIndex(source, i, nil) {
                frames.append(frame)
            }
            
            if let propertyCFDict = CGImageSourceCopyPropertiesAtIndex(source, i, nil) {
                let propertyDict = NSDictionary(dictionary: propertyCFDict)
                if let height = propertyDict.valueForKey((kCGImagePropertyPixelHeight as String)) as? NSNumber {
                    GifHeight = CGFloat(height.floatValue)
                }
                
                if let width = propertyDict.valueForKey((kCGImagePropertyPixelWidth as String)) as? NSNumber {
                    GifWidth = CGFloat(width.floatValue)
                }
                
                if let GIFCFDict = propertyDict.valueForKey((kCGImagePropertyGIFDictionary as String)) {
                    let GIFDict = NSDictionary(dictionary: GIFCFDict as! [NSObject : AnyObject])
                    if let delaytime = GIFDict.valueForKey((kCGImagePropertyGIFDelayTime as String )) as? NSNumber {
                        delayTimes.append(delaytime)
                        totalTimes += delaytime.floatValue
                    }
                }
            }
        }
    }
}


extension LGGIFPlayer {
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            gifPlayView.layer.contents = nil
            gifPlayView.removeFromSuperview()
        }
    }
}
