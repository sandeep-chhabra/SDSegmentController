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

//    func segmentDidBeginDragging(offset: CGPoint) {
//        segmentControl.beginMoveToNextSegment()
//        
//        let progress = offset.x/self.view.frame.size.width 
//        segmentControl.setProgressToNextSegment(progress: abs(progress) , direction: offset.x < 0 ? .forward : .backward)
//    }
    
//    func segmentDidEndDragging() {
//        self.segmentControl.endMoveToNextSegment()
////        _lastSelectedSegmentIndex = segmentControl.selectedSectionIndex
//    }

    func segmentDidBeginDragging(progress: CGFloat, direction: SDMoveDirection) {
        segmentControl.setProgressToNextSegment(progress: abs(progress) , direction: direction)
    }
    
    func segmentDidEndDragging(selectedPage: Int) {
        
        
//        print("segmentDidEndDragging : page : \(selectedPage)")
//            self.segmentControl.endMoveToNextSegment()
            //giving wrong page sometime
            self.segmentControl.selectSegment(segmentbButton: nil, index: selectedPage - 1) 

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
//                self.segmentControl.selectSegment(segmentbButton: nil, index:index)
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
        
        _pageController.setViewControllers([vc], direction: dir, animated: true , pageIndex: segmentControl.selectedSectionIndex + 1) { (completed) in
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



 protocol SDSegmentPageViewControllerDelegate:UIPageViewControllerDelegate {
   func segmentDidBeginDragging(progress:CGFloat , direction : SDMoveDirection)
    //TODO: SEND current section index - bug - page view controller allows to drag to mutiple view controllers at a single time
   func segmentDidEndDragging(selectedPage : Int)

}


class SDSegmentPageViewController: UIPageViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate{
 
    private   var _panGest : UIPanGestureRecognizer!
    
    var startPage : Int = 1
    var ignore = false
    var offsetX : CGFloat = 0
    
    var scrollDelegate:SDSegmentPageViewControllerDelegate?

    var isSegemntSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let scrollVu = self.getScrollView(mainView: self.view)
       
//        _panGest = scrollVu?.panGestureRecognizer
//        _panGest.addTarget(self, action: #selector(handlePan(panGest:)))
        
        scrollVu?.panGestureRecognizer.maximumNumberOfTouches = 1
        scrollVu?.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func handlePan(panGest:UIPanGestureRecognizer)  {
        
        switch panGest.state {
        case .began,.changed:
//            scrollDelegate?.segmentDidBeginDragging?(offset: panGest.translation(in: self.view))
        break
        case .ended:
//            scrollDelegate?.segmentDidEndDragging()
        break
        default:
            break
        }

    }
    
//MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //On every the page on scroll view
        //scrollview content offset x starts from pagewidth to 2*pagewidth in case of forward
        //content offset x changes from pagewidth to 0 in case of backward
        //Then reset
        

        if ignore || isSegemntSelected {
            return
        }
        
        offsetX = scrollView.contentOffset.x
        
        let pageWidth : CGFloat = scrollView.frame.size.width
        let fractionalPage = offsetX / pageWidth
        let progress = abs(1 - fractionalPage)

        let dir:SDMoveDirection = fractionalPage >= 1 ? .forward : .backward

        if progress == 1{
            ignore = true
        }
        
//        print("scrollViewDidScroll PROGRESS: \(progress), startPage:\(startPage), direction:\(dir)")


        scrollDelegate?.segmentDidBeginDragging(progress: progress, direction: dir)

        
  //TODO:FIX ISSUE OF MULTIPLE PAGE DRAGS AT SINGLE TIME
        //ALTERNATIVE  - pan gesture number of touches to 1 to disable
        
//        print("scrollViewDidScroll : \((scrollView.contentOffset.x * CGFloat(previousPage))/pageWidth)")
//
//        let totalProg = (scrollView.contentOffset.x * CGFloat(previousPage))/pageWidth
//        let pageNumber = trunc(totalProg)
//        let targetPage = dir == .forward ? pageNumber + 1 : pageNumber
//        let prog = totalProg - pageNumber
//        
//        print("scrollViewDidScroll : \(targetPage), progress:\(prog), direction:\(dir) ")

        
    }
    
   
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("scrollViewDidEndDecelerating")
        if isSegemntSelected {
            return
        }
        
        ignore = false
        
        let pageWidth : CGFloat = scrollView.frame.size.width;
        let fractionalPage = offsetX / pageWidth;

        if fractionalPage > 1.5{
            //did move to next page
            startPage += 1
        }
        else if fractionalPage < 0.5 && startPage != 1{
            //Did move to previous page
            startPage -= 1
        }
        
        scrollDelegate?.segmentDidEndDragging(selectedPage: startPage)

    }
    
//MARK: setViewControllers with page index as user can select any page directly so startPage can not be calculated
    func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, pageIndex:Int, completion: @escaping ((Bool) -> Void)) {
//        print("setViewControllers : start page : \(pageIndex)")
        isSegemntSelected = true
        startPage = pageIndex
        setViewControllers(viewControllers, direction: direction, animated: animated) { (complete) in
            completion(complete)
            self.isSegemntSelected = false
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
