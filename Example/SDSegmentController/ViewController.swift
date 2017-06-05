//
//  ViewController.swift
//  SDSegmentController
//
//  Created by sandeep-chhabra on 06/05/2017.
//  Copyright (c) 2017 sandeep-chhabra. All rights reserved.
//

import UIKit
import SDSegmentController

class ViewController: UIViewController,SDSegmentControllerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let segmentVc = SDSegmentController.init(sectionTitles: ["Title 1","1","Title 2","2","Title 3","3","Title 4","4"])
        segmentVc.view.frame = self.view.bounds
        self.addChildViewController(segmentVc)
        self.view.addSubview(segmentVc.view)
        
        segmentVc.segmentControl.segmentWidthStyle = .dynamic
        segmentVc.dataSource = self
        segmentVc.addSegments()
        
        //        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        get{ return true}
    }
    
    //MARK: - SDSegmentViewControllerDataSource
    func viewControllerAt(segmentIndex: Int) -> UIViewController {
        let vc = UIViewController()
        
        let labl = UILabel.init(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
        labl.text = "View Controller : \(segmentIndex + 1)"
        labl.center = vc.view.center
        labl.textAlignment = .center
        labl.textColor = UIColor.white
        
        vc.view.addSubview(labl)
        vc.view.backgroundColor = UIColor.blue
        
        return vc
    }
    
}
