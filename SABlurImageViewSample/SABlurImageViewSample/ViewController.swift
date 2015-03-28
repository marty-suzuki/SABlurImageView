//
//  ViewController.swift
//  SABlurImageViewSample
//
//  Created by 鈴木大貴 on 2015/03/27.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delay = 3 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 3.0)
            self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
            let imageView = SABlurImageView(image: image)
            imageView.configrationForBlurAnimation(duration: 0.25)
        
            self.view.addSubview(imageView)
            imageView.startBlurAnimation2()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

