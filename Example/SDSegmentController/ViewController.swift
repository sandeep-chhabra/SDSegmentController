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
        
        let segmentVc = //SDSegmentController.init(sectionTitles: ["INBOX","music","Books","images","library"])
            SDSegmentController.init(sectionImages: [#imageLiteral(resourceName: "music"),#imageLiteral(resourceName: "home"),#imageLiteral(resourceName: "book"),#imageLiteral(resourceName: "books")], selectedSectionImages: [#imageLiteral(resourceName: "musicSelected"),#imageLiteral(resourceName: "homeSelected"),#imageLiteral(resourceName: "bookSelected"),#imageLiteral(resourceName: "booksSelected")], sectionTitles: ["Title 1","Title 2aaa","Title 3aaaaa","Title 4sssssssss"] )
        
        segmentVc.segmentControl.sectionInset = 10

        segmentVc.view.frame = self.view.bounds
        segmentVc.segmentHeight = 80
        segmentVc.segmentControl.segmentWidthStyle = .fixed
        
        segmentVc.segmentControl.selectedSectionIndex  = 3

        self.addChildViewController(segmentVc)
        self.view.addSubview(segmentVc.view)
        
        segmentVc.dataSource = self
        
        //Use dispatch async if using auto layout
        segmentVc.addSegments()
        
        
        // Customize segment views
        if let vu = segmentVc.viewAt(segmentIndex:0)
        {
            let x = vu.frame.size.width  - (20)
            let countLabel = UILabel(frame: CGRect(x: x, y:0 , width:20 , height: 20))
            countLabel.center.y = vu.center.y
           
            countLabel.text = "5"
            countLabel.backgroundColor = UIColor.red
            countLabel.textColor = UIColor.white
            countLabel.font = UIFont.systemFont(ofSize: 12)
            
            vu.addSubview(countLabel)
            countLabel.layer.masksToBounds = true
            countLabel.layer.cornerRadius = 10 // height/2
            countLabel.textAlignment = .center
        }
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            //Clears all view controllers in cache now viewControllerAt(segmentIndex: Int) will be called again on scrolling
            segmentVc.clearCache()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        get{ return true}
    }
    
    //MARK: - SDSegmentControllerDataSource
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
