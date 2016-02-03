# LGGIFKit
to general GIF and play GIF type file~

##preView
![demo](https://github.com/jamy0801/LGGIFKit/blob/master/gif/1.gif)

## general GIF
```code
        let filepath = NSBundle.mainBundle().pathForResource("video.mp4", ofType: nil)
        let videoPath = NSURL(fileURLWithPath: filepath!)
        LGGIFGeneral.generalGIFFromUrl(videoPath, loopCount: 0, FPS: 30) { (gifUrl) -> Void in
        // complection block
        }
```

## play GIF
```code
let gifView = LGGIFPlayer(frame: (self.view?.bounds)!, fileUrl: gifUrl)
            self.view.addSubview(gifView!)
            gifView?.startAnimation()
```

