//
//  SDSegmentControl.swift
//  SDSegmentController
//
//  Created by Sandeep Chhabra on 29/05/17.
//  Copyright © 2017 Sandeep Chhabra. All rights reserved.
//



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
        guard let imageSize = self.imageView?.image?.size,
            let text = self.titleLabel?.text,
            let font = self.titleLabel?.font
            else { return }
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + padding), right: 0.0)
        let labelString = NSString(string: text)
        let titleSize = labelString.size(attributes: [NSFontAttributeName: font])
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + padding), left: 0.0, bottom: 0.0, right: -titleSize.width)
        
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }
    
    func centerVertically() {
        centerVeticallyWith(padding:5)
    }
    
}

public class SDButton:UIButton{
    override public var isSelected: Bool{
        set (val){
            super.isSelected = val
            centerVertically()
        }
        get{
            return super.isSelected
        }
    }
    
}

fileprivate extension UIImage{
    func resizeImage( newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        self.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        image.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


public protocol SDSegmentControlDelegate {
    //delegate method called aways even when user selects segment
    func segmentControl(segmentControl:SDSegmentControl, willSelectSegmentAt index:Int)
    func segmentControl(segmentControl:SDSegmentControl, didSelectSegmentAt index:Int)
    
}

open class SDSegmentControl: UIControl {

    override open func awakeFromNib() {
//        NSLog("awwake from nib")
    }
    
    public var delegate: SDSegmentControlDelegate?

 

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
    
    
    // inset applied to left and right of section
    public var sectionInset:CGFloat = 0

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
        sectionInset = 10
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
        
        sectionInset = 10
        _scrollView = UIScrollView()
        _selectionIndicator = UIView()
        
        _sectionTitles = ["this","is","test","for","segments"]
        titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 67/255, green: 67/255, blue: 67/255, alpha: 1), NSFontAttributeName : UIFont.systemFont(ofSize: 18)]
        selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 84/255, green: 182/255, blue: 74/255, alpha: 1), NSFontAttributeName : UIFont.systemFont(ofSize: 18)]

        super.init(coder : aDecoder)
    }
    


    
    // MARK: - Draw segments
  open  func drawSegments(){
        
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
        
    
        rescaleImagesIfNeeded()
    
        //Add sections
        let maxWidth = self.maxWidth()
        var x:CGFloat = 0  //sectionMargin
        let count = numberOfSegments
        
        for index in 0...count-1 {
            let btnWidth = ( segmentWidthStyle == .fixed ?  maxWidth :  widthAt(index: index)) + (sectionInset * 2)
            let rect = CGRect(x: x, y: CGFloat(0), width: btnWidth ,height: self.frame.size.height - selectionIndicatorHeight )
            let button = SDButton(frame:rect )
            button.addTarget(self, action: #selector(sectionSlected(button:)), for: UIControlEvents.touchUpInside)
            
            button.tag = index + 999
            
            //temp
            button.backgroundColor = sectionColor
            //
            
            switch _controlType {
            case .image:
                if var image = _sectionImages?[index] {
                    let height = image.size.height
                    if height > self.frame.size.height{
                     image = image.resizeImage( newHeight: self.frame.size.height)
                    }
                    button.setImage(image, for: .normal)

                }
                if var selectedImage = _selectedSectionImages?[index] {
                    let height = selectedImage.size.height
                    if height > self.frame.size.height{
                        selectedImage = selectedImage.resizeImage( newHeight: self.frame.size.height)
                    }
                    button.setImage(selectedImage, for: .selected)
                }
                
                break
            case .imageText:
                
                
                let attrTitle = NSAttributedString(string: (_sectionTitles?[index])!, attributes: titleTextAttributes)
                let attrTitleSelected = NSAttributedString(string: (_sectionTitles?[index])!, attributes: selectedTitleTextAttributes)
                
                button.setAttributedTitle(attrTitle, for: .normal)
                button.setAttributedTitle(attrTitleSelected, for: .selected)
                
                button.setImage(_sectionImages?[index], for: .normal)
                button.setImage(_selectedSectionImages?[index], for: .selected)

                //call after setting image and text
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
    
    
    func rescaleImagesIfNeeded(){
        
        if _controlType != .imageText && _controlType != .image {
            return
        }
        
        let padding : CGFloat = 5
        let topInset : CGFloat = 7
        let bottomInset : CGFloat = 7

        for index in 0..<numberOfSegments{
            
            var titleHeight : CGFloat = 0
            var selectedTitleHeight : CGFloat = 0

            
            if _controlType == .imageText {
                let attrTitle = NSAttributedString(string: (_sectionTitles?[index])!, attributes: titleTextAttributes)
                let attrTitleSelected = NSAttributedString(string: (_sectionTitles?[index])!, attributes: selectedTitleTextAttributes)
                
                titleHeight = attrTitle.size().height + padding
                selectedTitleHeight = attrTitleSelected.size().height + padding
            }
           
            
            if let image = _sectionImages?[index] , let selectedImage = _selectedSectionImages?[index] {
                
                
                //Match heights of images and selected images by taking min so that chances of rescaling are reduced in next step
                let minHeight = min(image.size.height, selectedImage.size.height)
                if image.size.height != selectedImage.size.height {
                    if image.size.height > selectedImage.size.height{
                        _sectionImages?[index] = image.resizeImage( newHeight: minHeight)
                    }
                    else{
                        _selectedSectionImages?[index] = selectedImage.resizeImage( newHeight: minHeight)
                    }
                }
                
                
                //rescale section images if they do not fit in button
                let totalHeight = minHeight + titleHeight + topInset + bottomInset
                let totalSelectedHeight = minHeight + selectedTitleHeight + topInset + bottomInset
                
                if totalHeight > self.frame.size.height{
                    _sectionImages?[index] = image.resizeImage( newHeight: self.frame.size.height - titleHeight - topInset - bottomInset)
                }
                
                if totalSelectedHeight > self.frame.size.height{
                    _selectedSectionImages?[index] = selectedImage.resizeImage( newHeight: self.frame.size.height - selectedTitleHeight - topInset - bottomInset)
                }
            }
            
        }
        
    }
    
    
    //MARK: Drawing helpers
  
    func attributedTitleAt(index:Int) -> NSAttributedString {
        let title = _sectionTitles?[index]
        let textAtt = selectedSectionIndex == index ? selectedTitleTextAttributes : titleTextAttributes
        
        return NSAttributedString.init(string: title!, attributes: textAtt)
    }
    

    func maxWidth() -> CGFloat  {
        
        var maxWidth:CGFloat = 0
        
        let count = numberOfSegments
       
        for i in 0...count-1{
            let currentWidth = widthAt(index: i)
            maxWidth = currentWidth > maxWidth ? currentWidth : maxWidth
        }
        
        //IF the max width can be increased to fill screen
//        let calcMaxScrWidth = (self.frame.size.width - (CGFloat(numberOfSegments+1) * sectionMargin))/CGFloat( numberOfSegments)
        let calcMaxScrWidth = (self.frame.size.width - (CGFloat(numberOfSegments) * (sectionInset*2)))/CGFloat( numberOfSegments)
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
            let image  = _sectionImages![index]
            let selectedImage = _selectedSectionImages![index]
            return max(attrStr.size().width,image.size.width, selectedImage.size.width)
        case .text:
            let attrStr = self.attributedTitleAt(index: index)
            return  attrStr.size().width
        }
        
    }
    
    
  public  func viewAt(segmentIndex:Int) -> UIView? {
        return self.viewWithTag(segmentIndex+999)
    }
  
    //MARK: - Action for sections tap
    func sectionSlected(button:UIButton) {
       
        selectSegment(segmentbButton: button,index: nil, shouldSendAction: true)
    }
    
    
  open  func selectSegment(segmentbButton:UIButton?,index:Int?)  {
        
        selectSegment(segmentbButton: segmentbButton, index: index, shouldSendAction: false)
    }

    
   private func selectSegment(segmentbButton:UIButton?,index:Int? , shouldSendAction:Bool)  {
        
        selectSegment(segmentbButton: segmentbButton, index: index, shouldSendAction: shouldSendAction, isReselect: false)
        
    }
    
    private  func selectSegment(segmentbButton:UIButton?,index:Int? , shouldSendAction:Bool, isReselect:Bool){
        
        
        switch (index , segmentbButton) {
        case let (x,y) where x == nil && y == nil:
            return
        case ( let x , _) where x != nil :
            if x! > numberOfSegments - 1 || x! < 0 {
                return
            }
        default:
            break
        }
        
        
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
        
        //delegate method called always even when user selects segment
        self.delegate?.segmentControl(segmentControl: self, willSelectSegmentAt: currentSectionIndex)
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
            //delegate method called always even when user selects segment
            self.delegate?.segmentControl(segmentControl: self, didSelectSegmentAt: currentSectionIndex)
        }
    }
    
  //MARK: - Refresh
 open   func refreshSegemts() {
//        self.setNeedsDisplay()
    self.drawSegments()
    }
    
//MARK: - Drag to next
    
  open  func beginMoveToNextSegment(){
        
        //disable touch
    }
    
  open  func endMoveToNextSegment(){
        
        switch (selectedSectionIndex,_currentDirection) {
        case (0, .backward):
            return
        case (numberOfSegments - 1,.forward):
            return
        default:
//            print("Default case endMoveToNextSegment \(selectedSectionIndex), \(_currentDirection), \(_currentProgress)")
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
    
  open  func setProgressToNextSegment(progress:CGFloat , direction : SDMoveDirection){
        
        
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
            _currentProgress = 0
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
            x = currentFrame.origin.x + ((currentFrame.size.width ) * _currentProgress)
            width = nxtFrame.size.width
           break
        case (.forward , .dynamic):
            x = currentFrame.origin.x + ((currentFrame.size.width ) * _currentProgress)
            width = currentFrame.size.width + (nxtFrame.size.width - currentFrame.size.width) * _currentProgress
            break
        case (.backward , .fixed):
            x = currentFrame.origin.x - ((currentFrame.size.width ) * _currentProgress)
            width = nxtFrame.size.width
            break
        case (.backward , .dynamic):
            x = currentFrame.origin.x - ((nxtFrame.size.width ) * _currentProgress)
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
