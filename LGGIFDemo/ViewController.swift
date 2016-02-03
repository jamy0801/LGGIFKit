//
//  ViewController.swift
//  LGGIFDemo
//
//  Created by gujianming on 16/2/2.
//  Copyright © 2016年 jamy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.purpleColor()
        indicator.startAnimating()
        let filepath = NSBundle.mainBundle().pathForResource("video.mp4", ofType: nil)
        let videoPath = NSURL(fileURLWithPath: filepath!)
        LGGIFGeneral.generalGIFFromUrl(videoPath, loopCount: 0, FPS: 30) { (gifUrl) -> Void in
            self.indicator.stopAnimating()
            self.indicatorView.removeFromSuperview()
            let gifView = LGGIFPlayer(frame: (self.view?.bounds)!, fileUrl: gifUrl)
            self.view.addSubview(gifView!)
            gifView?.startAnimation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

