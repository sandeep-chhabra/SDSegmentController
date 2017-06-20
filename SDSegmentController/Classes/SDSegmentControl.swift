//
//  SDSegmentControl.swift
//  SDSegmentController
//
//  Created by Sandeep Chhabra on 29/05/17.
//  Copyright © 2017 Sandeep Chhabra. All rights reserved.
//



//TODO : ImageTextType
//TODO : ERROR HANDLING FOR WRONG OR NOT INPUT
//TODO: HANDLING FOR IMAGE SIZE BIGGER THAN OWN SIZE


import UIKit

public enum SDSegmentWidth {
    case dynamic
    case fixed
}

public enum SDSegmentControlType{
    case text
    case image
    case imageText

}
public enum SDMoveDirection{
    case forward
    case backward
}


fileprivate extension UIButton {
    func centerVeticallyWith(padding:CGFloat){
        if let imageSize = self.imageView?.frame.size, let titleSize = self.titleLabel?.frame.size {
            let totalHeight = imageSize.height + titleSize.height + padding
            
            self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: titleSize.width, bottom: 0, right: 0)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
            self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func centerVertically() {
        centerVeticallyWith(padding:7)
    }
}


public class SDSegmentControl: UIControl {

    override public func awakeFromNib() {
//        NSLog("awwake from nib")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func draw(_ rect: CGRect) {
        // Drawing code
//        NSLog("draw rect " )

        DispatchQueue.main.async {
            self.drawSegments()
        }
    }
 

    //set these values accordingly if using default init or to change segments at runtime
    public var _sectionTitles:[String]?
    public var _sectionImages:[UIImage]?
    public var _selectedSectionImages:[UIImage]?
    public var _controlType:SDSegmentControlType = .text
    
    private var _scrollView:UIScrollView!
    private var _selectionIndicator : UIView
   
    //movement to next segment
    private var _currentProgress : CGFloat = 0
    private var _currentDirection : SDMoveDirection = .forward
    
    public var selectionIndicatorHeight :CGFloat = 4
    public var segmentWidthStyle : SDSegmentWidth = .fixed
    
    public var selectionIndicatorColor:UIColor =  UIColor.init(red: 84/255, green: 182/255, blue: 74/255, alpha: 1)
    public var sectionColor:UIColor = UIColor.white
    
    public var titleTextAttributes : [String: AnyObject]
    public var selectedTitleTextAttributes : [String: AnyObject]
    public var selectedSectionIndex : Int = 0
    public var lastSelectedSectionIndex :Int = 0
    
    
    public var sectionMargin:CGFloat = 0

    public var numberOfSegments : Int {
        get{
            var count = 0
            
            switch _controlType {
            case .image:
                count = (_sectionImages?.count)!
                break
            case .imageText:
                count = (_sectionTitles?.count)!
                break
            case .text:
                count = (_sectionTitles?.count)!
                break
            }
            
            return count
        }
    }

   public var moveDirection : SDMoveDirection {
        get{
            return lastSelectedSectionIndex > selectedSectionIndex ? .backward : .forward
        }
    }
    
    //MARK: - Initialization
    
   public init(){
        sectionMargin = 10
        _scrollView = UIScrollView()
        _selectionIndicator = UIView()
        
        _sectionTitles = ["this","is","test","for","segments"]
        titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 67/255, green: 67/255, blue: 67/255, alpha: 1), NSFontAttributeName : UIFont.systemFont(ofSize: 18)]
        selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 84/255, green: 182/255, blue: 74/255, alpha: 1), NSFontAttributeName : UIFont.systemFont(ofSize: 18)]
        
        super.init(frame: CGRect())
    }
    
    convenience public init(sectionTitles:[String]){
        self.init()
        _sectionTitles = sectionTitles
        _controlType = .text
    }
    
    convenience public init(sectionImages:[UIImage],selectedSectionImages:[UIImage]) {
        self.init()

        _sectionImages = sectionImages
        _selectedSectionImages = selectedSectionImages
        _controlType = .image
    }
    
    convenience public init(sectionImages:[UIImage],selectedSectionImages:[UIImage],sectionTitles:[String]) {
        self.init()
        _sectionImages = sectionImages
        _selectedSectionImages = selectedSectionImages
        _sectionTitles = sectionTitles
        _controlType = .imageText
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
//        NSLog("init coder")
        sectionMargin = 10
        _scrollView = UIScrollView()
        _selectionIndicator = UIView()
        
        _sectionTitles = ["this","is","test","for","segments"]
        titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 67/255, green: 67/255, blue: 67/255, alpha: 1), NSFontAttributeName : UIFont.systemFont(ofSize: 18)]
        selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 84/255, green: 182/255, blue: 74/255, alpha: 1), NSFontAttributeName : UIFont.systemFont(ofSize: 18)]

        super.init(coder : aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    

    //
//    
//    func setSelectedSegment(index:Int,animated:Bool)  {
//        
//        switch _controlType {
//        case .image:
//            
//        break
//        case .imageText:
//            break
//        case .text:
//            break
//            
//        }
//        
//    }
    
    // MARK: - Draw segments
  public  func drawSegments(){
        
        NSLog("draw segments")
        _scrollView.removeFromSuperview()
        _scrollView = UIScrollView()
        
        //Add scroll view
        _scrollView.isDirectionalLockEnabled = true
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.frame = self.bounds
        self.addSubview(_scrollView)
        
        
        //temp
        _scrollView.backgroundColor = sectionColor
        self.backgroundColor = UIColor.gray
        
        
        //Add sections
        let maxWidth = self.maxWidth()
        var x:CGFloat = 0  //sectionMargin
        let count = numberOfSegments
        
        for index in 0...count-1 {
            let btnWidth = ( segmentWidthStyle == .fixed ?  maxWidth :  widthAt(index: index)) + sectionMargin
            let rect = CGRect(x: x, y: CGFloat(0), width: btnWidth ,height: self.frame.size.height - selectionIndicatorHeight )
            let button = UIButton(frame:rect )
            button.addTarget(self, action: #selector(sectionSlected(button:)), for: UIControlEvents.touchUpInside)
            
            button.tag = index + 999
            
            //temp
            button.backgroundColor = sectionColor
            //
            
            switch _controlType {
            case .image:
                button.setImage(_sectionImages?[index], for: .normal)
                button.setImage(_selectedSectionImages?[index], for: .selected)
                break
            case .imageText:
                button.setImage(_sectionImages?[index], for: .normal)
                button.setImage(_selectedSectionImages?[index], for: .selected)
                
                let attrTitle = NSAttributedString(string: (_sectionTitles?[index])!, attributes: titleTextAttributes)
                let attrTitleSelected = NSAttributedString(string: (_sectionTitles?[index])!, attributes: selectedTitleTextAttributes)
                
                button.setAttributedTitle(attrTitle, for: .normal)
                button.setAttributedTitle(attrTitleSelected, for: .selected)
                
                button.centerVertically()
                
                break
            case .text:
                let attrTitle = NSAttributedString(string: (_sectionTitles?[index])!, attributes: titleTextAttributes)
                let attrTitleSelected = NSAttributedString(string: (_sectionTitles?[index])!, attributes: selectedTitleTextAttributes)
                
                button.setAttributedTitle(attrTitle, for: .normal)
                button.setAttributedTitle(attrTitleSelected, for: .selected)
                
                break
                
            }
            
            
            _scrollView.addSubview(button)
            
            x = x+btnWidth //+ sectionMargin
        }
        
        _scrollView.contentSize = CGSize(width: x, height: self.frame.size.height)
        
        
        //check selected section less than total section
        selectedSectionIndex = selectedSectionIndex < numberOfSegments ? selectedSectionIndex : 0
        
        //Add Selection indicator
        let selectedView = (_scrollView.viewWithTag(selectedSectionIndex + 999)) as! UIButton
        var frame = selectedView.frame
        frame.origin.y += (frame.size.height)
        frame.size.height = selectionIndicatorHeight
        _selectionIndicator.frame = frame
        _scrollView.addSubview(_selectionIndicator)
        _selectionIndicator.backgroundColor = selectionIndicatorColor
        //
        
        //change state of selected section
        selectedView.isSelected = true
        
        _scrollView.scrollRectToVisible(selectedView.frame, animated: true)
    }
    
    //MARK: Drawing helpers
    func attributedTitleAt(index:Int) -> NSAttributedString {
        let title = _sectionTitles?[index]
        let textAtt = selectedSectionIndex == index ? selectedTitleTextAttributes : titleTextAttributes
        
        return NSAttributedString.init(string: title!, attributes: textAtt)
    }
    
//NOT USED
    func sizeForSegmentAt(index:Int) -> CGSize {

        let isSelectedIndex : Bool = (selectedSectionIndex == index)
        switch _controlType {
        case .image:
            let image = isSelectedIndex ? _selectedSectionImages?[index] : _sectionImages?[index]
                return image!.size
        case .imageText:
            return CGSize()
        case .text:
            let title = self.attributedTitleAt(index: index)
            return title.size()
            
        }
    }
//
    func maxWidth() -> CGFloat  {
        
        var maxWidth:CGFloat = 0
        
//        switch _controlType {
//        case .image:
//            for item in arr{
//                let image  = item as! UIImage
//                maxWidth = maxWidth < image.size.width ? image.size.width : maxWidth
//            }
//            break
//        case .imageText:
//            break
//        case .text:
//            for i in 0...arr.count - 1{
//                let attrStr = self.attributedTitleAt(index: i)
//                maxWidth = maxWidth < attrStr.size().width ? attrStr.size().width : maxWidth
//            }
//        }
        
        let count = numberOfSegments
       
        for i in 0...count-1{
            let currentWidth = widthAt(index: i)
            maxWidth = currentWidth > maxWidth ? currentWidth : maxWidth
        }
        
        //IF the max width can be increased to fill screen
//        let calcMaxScrWidth = (self.frame.size.width - (CGFloat(numberOfSegments+1) * sectionMargin))/CGFloat( numberOfSegments)
        let calcMaxScrWidth = (self.frame.size.width - (CGFloat(numberOfSegments) * sectionMargin))/CGFloat( numberOfSegments)
        maxWidth =  calcMaxScrWidth > maxWidth ? calcMaxScrWidth : maxWidth
        
        return maxWidth
    }
 
    func widthAt(index:Int) -> CGFloat  {
        
        
        switch _controlType {
        case .image:
                let image  = _sectionImages?[index]
                return image!.size.width
        case .imageText:
            let attrStr = self.attributedTitleAt(index: index)
            let image  = _sectionImages?[index]
            return max(attrStr.size().width, (image?.size.width)!)
        case .text:
                let attrStr = self.attributedTitleAt(index: index)
                return  attrStr.size().width
        }
        
    }
    
    
    
  
    //MARK: - Action for sections tap
    func sectionSlected(button:UIButton) {
       
        selectSegment(segmentbButton: button,index: nil, shouldSendAction: true)
    }
    
    
  public  func selectSegment(segmentbButton:UIButton?,index:Int?)  {
        
        selectSegment(segmentbButton: segmentbButton, index: index, shouldSendAction: false)
    }

    
   private func selectSegment(segmentbButton:UIButton?,index:Int? , shouldSendAction:Bool)  {
        
        selectSegment(segmentbButton: segmentbButton, index: index, shouldSendAction: shouldSendAction, isReselect: false)
        
    }
    
  private  func selectSegment(segmentbButton:UIButton?,index:Int? , shouldSendAction:Bool, isReselect:Bool){
        
        let currentSelectionView = segmentbButton != nil ? segmentbButton : (_scrollView.viewWithTag(index! + 999) as! UIButton)
        let currentSectionIndex = (currentSelectionView?.tag)! - 999
        
        if currentSectionIndex == self.selectedSectionIndex && isReselect == false
        {
            return
        }
        
        if isReselect == false {
            lastSelectedSectionIndex = self.selectedSectionIndex
            self.selectedSectionIndex = currentSectionIndex
        }
       
        
        if shouldSendAction {
            self.sendActions(for: .valueChanged)
        }
    
        _selectionIndicator.layer.removeAllAnimations()
    
        _scrollView.scrollRectToVisible((currentSelectionView?.frame)!, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            
                let newPosition = CGRect(x: (currentSelectionView?.frame.origin.x)!, y: self._selectionIndicator.frame.origin.y, width: (currentSelectionView?.frame.size.width)!, height: self.selectionIndicatorHeight)
            
                self._selectionIndicator.frame = newPosition
            })
            { (completed) in
                    if isReselect == false{
                        currentSelectionView?.isSelected = true
                        let lastSelectedView = self._scrollView.viewWithTag(self.lastSelectedSectionIndex+999) as! UIButton
                        lastSelectedView.isSelected = false
                    }
            }
    }
  //MARK: - Refresh
 public   func refreshSegemts() {
        self.setNeedsDisplay()
    }
    
//MARK: - Drag to next
    
  public  func beginMoveToNextSegment(){
        
        //disable touch
    }
    
  public  func endMoveToNextSegment(){
        
        switch (selectedSectionIndex,_currentDirection) {
        case (0, .backward):
            return
        case (numberOfSegments - 1,.forward):
            return
        default:
            break
        }
        
        
        
        if _currentProgress > 0.5 {
            //move to next section
            selectSegment(segmentbButton: nil, index: selectedSectionIndex + (_currentDirection == .forward ? 1 : -1) , shouldSendAction: false)
        }
        else{
            //move back to deafult pos
            selectSegment(segmentbButton: nil, index: selectedSectionIndex  , shouldSendAction: false, isReselect: true)
        }
        
        //enable touch
    }
    
  public  func setProgressToNextSegment(progress:CGFloat , direction : SDMoveDirection){
        
        
        _currentDirection = direction

        switch (selectedSectionIndex,direction) {
        case (0,.backward):
            return
        case (numberOfSegments - 1,.forward):
            return
        default:
            break
        }
        
        switch progress {
        case let p where p <= 0:
            //move back to deafult pos
            selectSegment(segmentbButton: nil, index: selectedSectionIndex  , shouldSendAction: false, isReselect: true)
            return
        case let p where p >= 1:
            _currentProgress = 1
//        case let p where p > 0.5:
//            //TODO:select segment and deselect previous
//            break
//        case let p where p <= 0.5:
//            //TODO:deselect segment and select previous
//            break
        default:
            _currentProgress = progress
            break
        }
        
        let viewTag = selectedSectionIndex + (direction == .forward ? 1 : -1) + 999
       
        
        let nxtSegmentView = _scrollView.viewWithTag(viewTag) as! UIButton
        let nxtFrame = nxtSegmentView.frame

        let currentView = _scrollView.viewWithTag(selectedSectionIndex + 999) as! UIButton
        let currentFrame = currentView.frame
        
        var x : CGFloat = 0
        var width : CGFloat = 0
        let y = _selectionIndicator.frame.origin.y
        

        switch (direction , segmentWidthStyle) {
        case (.forward , .fixed):
            x = currentFrame.origin.x + ((currentFrame.size.width + sectionMargin) * _currentProgress)
            width = nxtFrame.size.width
           break
        case (.forward , .dynamic):
            x = currentFrame.origin.x + ((currentFrame.size.width + sectionMargin) * _currentProgress)
            width = currentFrame.size.width + (nxtFrame.size.width - currentFrame.size.width) * _currentProgress
            break
        case (.backward , .fixed):
            x = currentFrame.origin.x - ((currentFrame.size.width + sectionMargin) * _currentProgress)
            width = nxtFrame.size.width
            break
        case (.backward , .dynamic):
            x = currentFrame.origin.x - ((nxtFrame.size.width + sectionMargin) * _currentProgress)
            width = currentFrame.size.width + (nxtFrame.size.width - currentFrame.size.width) * _currentProgress
            break
      
        }
        
        _selectionIndicator.frame =  CGRect(x:x , y: y, width:width, height:selectionIndicatorHeight)
        
//        switch direction {
//        case .forward:
//            let x = currentFrame.origin.x  + (nxtFrame.size.width * _currentProgress)
//            _selectionIndicator.frame = CGRect(x:x , y: _selectionIndicator.frame.origin.y, width:nxtFrame.size.width * (segmentWidthStyle == .fixed ? 1 : _currentProgress), height:selectionIndicatorHeight)
//            break
//        default:
//            let x = currentFrame.origin.x  - (nxtFrame.size.width * _currentProgress)
//            NSLog("backx = \(x)")
//            _selectionIndicator.frame = CGRect(x:x , y: _selectionIndicator.frame.origin.y, width:nxtFrame.size.width * (segmentWidthStyle == .fixed ? 1 : _currentProgress), height:selectionIndicatorHeight)
//            
//            break
//        }
    }
    
    
}
