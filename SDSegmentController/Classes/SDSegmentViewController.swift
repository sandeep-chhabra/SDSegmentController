//
//  SDSegmentController.swift
//  SDSegmentController
//
//  Created by Sandeep Chhabra on 29/05/17.
//  Copyright © 2017 Sandeep Chhabra. All rights reserved.
//

import UIKit

public protocol SDSegmentControllerDataSource {
    func viewControllerAt(segmentIndex:Int) -> UIViewController
}

public protocol SDSegmentControllerDelegate {
    //delegate method called always even when user selects segment
    func segmentController(segmentController:SDSegmentController, willSelectSegmentAt index:Int)
    func segmentController(segmentController:SDSegmentController, didSelectSegmentAt index:Int)

}

open class SDSegmentController: UIViewController ,SDSegmentPageViewControllerDelegate, UIPageViewControllerDataSource , SDSegmentControlDelegate{
    
    public var dataSource: SDSegmentControllerDataSource!
    public var delegate: SDSegmentControllerDelegate?

    
   public var  segmentControl : SDSegmentControl!
   public var segmentHeight : CGFloat = 50
    
    private  let _pageController:SDSegmentPageViewController = SDSegmentPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
//    private var _lastSelectedSegmentIndex = 0
    
    public init(){
        segmentControl = SDSegmentControl()
        super.init(nibName: nil, bundle: nil)
        segmentControl.delegate = self
    }
    
    convenience public init(sectionTitles:[String]){
        self.init()
        segmentControl = SDSegmentControl(sectionTitles: sectionTitles)
    }
    
    convenience public init(sectionImages:[UIImage],selectedSectionImages:[UIImage]) {
        self.init()
        segmentControl = SDSegmentControl(sectionImages: sectionImages, selectedSectionImages: selectedSectionImages)
    }
    
    convenience public init(sectionImages:[UIImage],selectedSectionImages:[UIImage],sectionTitles:[String]) {
        self.init()
        segmentControl = SDSegmentControl(sectionImages: sectionImages, selectedSectionImages: selectedSectionImages, sectionTitles: sectionTitles)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        segmentControl = SDSegmentControl()
        super.init(coder:aDecoder)
        segmentControl.delegate = self
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        _pageController.delegate = self
        _pageController.scrollDelegate = self
        _pageController.dataSource = self
        
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged(segment:)), for: .valueChanged)
        
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public  func viewAt(segmentIndex:Int) -> UIView? {
        return self.segmentControl.viewAt(segmentIndex: segmentIndex)
    }

//MARK: - SDSegmentPageViewControllerDelegate
    func segmentDidBeginDragging(offset: CGPoint) {
        segmentControl.beginMoveToNextSegment()
        
        let progress = offset.x/self.view.frame.size.width 
        segmentControl.setProgressToNextSegment(progress: abs(progress) , direction: offset.x < 0 ? .forward : .backward)
    }
    
    func segmentDidEndDragging() {
        self.segmentControl.endMoveToNextSegment()
//        _lastSelectedSegmentIndex = segmentControl.selectedSectionIndex
    }

    
//MARK: - UIPageViewControllerDataSource
  public  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if (viewController.view.tag == 0) {
            return nil;
        }
        return self.getViewControllerAt(segmentIndex: viewController.view.tag - 1)
    }
    
    
   public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if (viewController.view.tag == segmentControl.numberOfSegments - 1) {
            return nil;
        }
        return self.getViewControllerAt(segmentIndex: viewController.view.tag + 1)
    }
    
    
    func getViewControllerAt(segmentIndex:Int) -> UIViewController {
        let vc =  dataSource.viewControllerAt(segmentIndex: segmentIndex)
        vc.view.tag = segmentIndex
        return vc
    }
    

    
//MARK: - UIPageViewControllerDelegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

    }
    
  public  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            let index = pageViewController.viewControllers?[0].view.tag ;
            if (index! < segmentControl.numberOfSegments) {
                self.segmentControl.selectSegment(segmentbButton: nil, index:index)
//                _lastSelectedSegmentIndex = index!;
            }
            else{
                
            }
        }
        
    }
    
    
//MARK: - Add segments
   open func addSegments() {
   
        //Add segment control
        segmentControl.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: segmentHeight)
        self.view.addSubview(segmentControl)
        segmentControl.drawSegments()
    
        //add pageController
        _pageController.view.frame = CGRect(x: 0, y: segmentHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - segmentHeight)
        self.addChildViewController(_pageController)
        self.view.addSubview(_pageController.view)
        
        let vc = self.getViewControllerAt(segmentIndex: segmentControl.selectedSectionIndex)
            _pageController.setViewControllers([vc], direction: .forward, animated: true) { (completed) in
                //last selected
//                self._lastSelectedSegmentIndex = self.segmentControl.selectedSectionIndex
            }
    }

    
//MARK : - SEGMENT CONTROL
    func segmentControlValueChanged(segment:SDSegmentControl)  {
        let dir : UIPageViewControllerNavigationDirection = segmentControl.moveDirection == .forward ? .forward : .reverse
       
        let vc = self.getViewControllerAt(segmentIndex: segmentControl.selectedSectionIndex)
            _pageController.setViewControllers([vc], direction: dir, animated: true) { (completed) in
                //last selected
//                self._lastSelectedSegmentIndex = self.segmentControl.selectedSectionIndex
            }
        
        
    }
//MARK : - SDSegmentControlDelegate
    public func segmentControl(segmentControl: SDSegmentControl, didSelectSegmentAt index: Int) {
        delegate?.segmentController(segmentController: self, didSelectSegmentAt: index)
    }
    public func segmentControl(segmentControl: SDSegmentControl, willSelectSegmentAt index: Int) {
        delegate?.segmentController(segmentController: self, willSelectSegmentAt: index)
    }
  
//MARK - Handle rotation
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            var frame =  self.segmentControl.frame
            frame.size.width = size.width
            self.segmentControl.frame = frame
            self.segmentControl.refreshSegemts()     
    }
}



@objc protocol SDSegmentPageViewControllerDelegate:UIPageViewControllerDelegate {
 @objc optional func segmentDidBeginDragging(offset:CGPoint)
    //TODO: SEND current section index - bug - page view controller allows to drag to mutiple view controllers at a single time
 @objc optional func segmentDidEndDragging()

}


class SDSegmentPageViewController: UIPageViewController, UIGestureRecognizerDelegate{
 
    private   var _panGest : UIPanGestureRecognizer!
//    private   var _swipeGest : UISwipeGestureRecognizer!
    
    
    var scrollDelegate:SDSegmentPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let scrollVu = self.getScrollView(mainView: self.view)
       
        _panGest = scrollVu?.panGestureRecognizer
        _panGest.addTarget(self, action: #selector(handlePan(panGest:)))
        
//        _swipeGest = scrollVu.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func handlePan(panGest:UIPanGestureRecognizer)  {
        
        switch panGest.state {
        case .began,.changed:
            scrollDelegate?.segmentDidBeginDragging?(offset: panGest.translation(in: self.view))
        break
        case .ended:
            scrollDelegate?.segmentDidEndDragging?()
        break
        default:
            break
        }

    }
    

    
    func getScrollView(mainView:UIView) -> UIScrollView! {
        for view in mainView.subviews {
            if let vu = view as? UIScrollView{
                return vu
            }
            return getScrollView(mainView: view)
            
        }
        
        return nil
    }
}
