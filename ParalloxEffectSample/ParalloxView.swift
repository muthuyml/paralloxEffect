//
//  ParalloxView.swift
//  ParalloxEffectSample
//
//  Created by Muthuraj on 22/11/16.
//  Copyright © 2016 Muthuraj. All rights reserved.
//

import UIKit

protocol ParalloxViewDelegate:class {
    func paralloxEffectProgress(paralloxView:ParalloxView,progress:CGFloat, direction:ParalloxDirection)
    func paralloxEffectStarted(paralloxView:ParalloxView, direction:ParalloxDirection)
    func paralloxEffectEnded(paralloxView:ParalloxView, direction:ParalloxDirection)
}

public enum ParalloxDirection {
    case up
    case down
}

class ParalloxView: UIView {
  
    private enum PanDirection {
        case left
        case right
        case top
        case bottom
    }
    
    @IBOutlet weak var headerView: UIView!
    //@IBOutlet weak var bodyView: UIView!
    @IBOutlet var contentContainerView: UIView!
    // Animatable constraints
    @IBOutlet weak var bodyViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    // for touch location tracking
    fileprivate var previousPoint = CGPoint(x: 0, y: 0)
    // Min , Max Values for Top Constraints to restrict beyond that point
    fileprivate var bodyViewMinValue = CGFloat(0)
    fileprivate var headerViewMinValue = CGFloat(0)
    fileprivate var bodyViewMaxValue = CGFloat(0) // be updated once constraints set
    fileprivate var headerViewMaxValue = CGFloat(0) // be updated once constraints set
    // delegate instance for notification
    @IBInspectable public weak var delegate:ParalloxViewDelegate?
    @IBOutlet weak var tableview: UITableView!
    
    //MARK: - initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createViews()
        setupViews()
    }
    
    //MARK: - Override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        // initial value for contraint may be 500 set by Xcode byDefault
        if bodyViewMaxValue == 0 || bodyViewMaxValue == 500 {
            bodyViewMaxValue = bodyViewTopConstraint.constant
        }
        if headerViewMaxValue == 0 || headerViewMaxValue == 500 {
            headerViewMaxValue = headerViewHeight.constant
        }
    }
    
    //MARK: - Pan related changes
    @IBAction func viewPanned(_ sender: UIPanGestureRecognizer) {
//        let direction = getPanningDirection(sender)
//        let velocity = sender.velocity(in: self)
//        var paralloxDirection:ParalloxDirection?
//        if direction == .top {
//            paralloxDirection = .up
//        } else if direction == .bottom {
//            paralloxDirection = .down
//        }
//        // check scrollablity
//        if let paralloxDirection = paralloxDirection {
//            //decideScrollablity(view: tableview, direction: paralloxDirection)
//        }
//        let currentLocation = sender.location(in: self)
//        switch sender.state {
//        case .began:
////            if let pxDirection = paralloxDirection {
////                self.delegate?.paralloxEffectStarted(paralloxView: self, direction: pxDirection)
////            }
//            //let currentLocation = sender.location(in: self)
//            previousPoint = currentLocation
//            break
//        case .changed:
//            //let currentLocation = sender.location(in: self)
//            //let difference = abs(previousPoint.y - currentLocation.y)
//            var calculatedTopConstraint = CGFloat(0)
//            //print("velocity : \(velocity)")
//            switch  direction {
//            case .left:
//                break
//            case .right:
//                break
//            case .top:
////                calculatedTopConstraint = bodyViewTopConstraint.constant - difference//previousPoint.y+velocity.y
////                var calculatedHeaderViewHeight = headerViewHeight.constant - (difference*0.5)
////                previousPoint = currentLocation
////                print("Top : calculated : \(calculatedTopConstraint)")
////                if calculatedTopConstraint < bodyViewMinValue {
////                    print("inside Top : calculated : \(calculatedTopConstraint)")
////                    calculatedTopConstraint = bodyViewMinValue
////                }
////                if calculatedHeaderViewHeight < headerViewMinValue {
////                    calculatedHeaderViewHeight = headerViewMinValue
////                }
////                if calculatedHeaderViewHeight > headerViewMaxValue {
////                    calculatedHeaderViewHeight = headerViewMaxValue
////                }
//                let calculatedValue = calculateNewValue(direction: .up, currentOffset: currentLocation)
//                previousPoint = currentLocation
//                // update body view top constraints
//                updateBodyViewConstraints(newValue: calculatedValue.bodyViewHeight)
//                updateHeaderViewConstraints(newValue: calculatedValue.headerViewHeight)
//                animateLayoutChanges()
//                break
//            case .bottom:
////                calculatedTopConstraint = bodyViewTopConstraint.constant + difference//previousPoint.y+velocity.y
////                var calculatedHeaderViewHeight = headerViewHeight.constant + (difference*0.5)
////                previousPoint = currentLocation
////                print("bottom : calculated : \(calculatedTopConstraint)")
////                if calculatedTopConstraint > bodyViewMaxValue {
////                    print("inside bottom : calculated : \(calculatedTopConstraint) and Max : \(bodyViewMaxValue)")
////                    calculatedTopConstraint = bodyViewMaxValue
////                }
////                if calculatedHeaderViewHeight > headerViewMaxValue {
////                    calculatedHeaderViewHeight = headerViewMaxValue
////                }
//                let calculatedValue = calculateNewValue(direction: .down, currentOffset: currentLocation)
//                previousPoint = currentLocation
//                // update body view top constraints
//                updateBodyViewConstraints(newValue: calculatedValue.bodyViewHeight)
//                updateHeaderViewConstraints(newValue: calculatedValue.headerViewHeight)
//                animateLayoutChanges()
//                break
//            }
////            if let pxDirection = paralloxDirection {
////                self.delegate?.paralloxEffectProgress(paralloxView: self, progress: 0.0, direction: pxDirection)
////            }
//            break
//        case .ended:
////            if let pxDirection = paralloxDirection {
////                self.delegate?.paralloxEffectEnded(paralloxView: self, direction: pxDirection)
////            }
////            if direction == .top || direction == .bottom {
////                var calculatedTopConstraint = CGFloat(0)
////                var calculatedHeaderViewHeight = CGFloat(0)
////                calculatedTopConstraint = bodyViewMaxValue
////                calculatedHeaderViewHeight = headerViewMaxValue
////                if direction == .top {
////                    calculatedTopConstraint = bodyViewMinValue
////                    calculatedHeaderViewHeight = headerViewMinValue
////                }
////                // update body view top constraints
////                updateBodyViewConstraints(newValue: calculatedTopConstraint)
////                updateHeaderViewConstraints(newValue: calculatedHeaderViewHeight)
////                animateLayoutChanges()
////            }
//            break
//        default:
//            break
//        }
    }
    
    func handlePan(sender:UIPanGestureRecognizer) {
        let currentPoint = sender.location(in: self)
        switch sender.state {
        case .began:
            previousPoint = currentPoint
            break
        case .changed:
            
            break
        case .ended:
            previousPoint = currentPoint
            break
        default:
            break
        }
    }
    
//    // decide body scroll view scrollablity
//    fileprivate func decideScrollablity(view:UIView, direction:ParalloxDirection) {
//        if isScrollView(view: tableview) {
//            var shouldScroll = true
//            if (bodyViewTopConstraint.constant > bodyViewMinValue) && (bodyViewTopConstraint.constant != bodyViewMaxValue) {//tableview.contentOffset.y < 0 {
//                print("Middle of parallox effect")
//                shouldScroll = false
//            } else if  bodyViewTopConstraint.constant == bodyViewMinValue{
//                shouldScroll = (direction == .up) ? true:false
//            }else if bodyViewTopConstraint.constant == bodyViewMaxValue {
//                print("content offset More")
//                shouldScroll = (direction == .up) ? false:true
//            }
//            //tableview.isScrollEnabled = shouldScroll
//        }
//    }
    
    // calculate New Position
    func calculateNewValue(direction:ParalloxDirection, currentOffset:CGPoint) -> (headerViewHeight:CGFloat,bodyViewHeight:CGFloat){
        let difference = abs(previousPoint.y - currentOffset.y)
        var calculatedTopConstraint = CGFloat(0)
        var calculatedHeaderViewHeight = CGFloat(0)
        if  direction == .down {
            calculatedTopConstraint = bodyViewTopConstraint.constant + difference
            calculatedHeaderViewHeight = headerViewHeight.constant + (difference*0.5)
            
            if calculatedTopConstraint > bodyViewMaxValue {
                calculatedTopConstraint = bodyViewMaxValue
            }
            if calculatedHeaderViewHeight > headerViewMaxValue {
                calculatedHeaderViewHeight = headerViewMaxValue
            }
            
        } else {
            calculatedTopConstraint = bodyViewTopConstraint.constant - difference
            calculatedHeaderViewHeight = headerViewHeight.constant - (difference*0.5)
            
            if calculatedTopConstraint < bodyViewMinValue {
                calculatedTopConstraint = bodyViewMinValue
            }
            if calculatedHeaderViewHeight < headerViewMinValue {
                calculatedHeaderViewHeight = headerViewMinValue
            }
        }
        //print("header Value : \(calculatedHeaderViewHeight) direction : \(direction)")
        return (calculatedHeaderViewHeight,calculatedTopConstraint)
    }
    
    /*
     fileprivate func handleParallax(_ offSetPoint: CGPoint)
     {
     if offSetPoint.y < 0
     {
     let originalHeight: CGFloat = AGConstants.screenWidth
     let scaleRatio = ((originalHeight + offSetPoint.y*(-1))/originalHeight)*1.0
     pictureHeaderView.pictureCV.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
     pictureHeaderView.pictureCV.frame.origin.y = offSetPoint.y
     }
     
     }
     */
    
    // MARK: - Action methods
    @IBAction func sendClicked(_ sender: UIButton) {
        print("send Clicked")
    }
    
    // MARK: - Helpers
    func createViews() {
        Bundle.main.loadNibNamed(String(describing: ParalloxView.self), owner: self, options: nil)
        self.addSubview(self.contentContainerView)
        self.contentContainerView.frame = self.bounds
    }
    
    func setupViews() {
//        tableview.isScrollEnabled = false
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        handlePanningForBodyView()
    }
    
    // Get Panning Direction
    private func getPanningDirection(_ panGesture:UIPanGestureRecognizer) -> PanDirection {
        var panDirection:PanDirection = .right
        let velocity = panGesture.velocity(in: self)
        if velocity.x < 0 {
            panDirection = .left
        }
        if (velocity.x > 0) {
            panDirection = .right
        }
        if (velocity.y < 0) {
            panDirection = .top
        }
        if velocity.y > 0 {
            panDirection = .bottom
        }
        return panDirection
    }
    // Get Parallox direction
    fileprivate func getParalloxDirection(currentOffset:CGPoint) -> ParalloxDirection{
        var direction = ParalloxDirection.down
        if previousPoint.y < currentOffset.y {
            direction = .up
        }
        return direction
    }
    
    private func getScaleFactorForYAxis(currentPoint:CGPoint) {
        // have to consider only y coordinate
    }
    
    fileprivate func updateBodyViewConstraints(newValue:CGFloat) {
        bodyViewTopConstraint.constant = newValue
    }
    
    fileprivate func updateHeaderViewConstraints(newValue:CGFloat) {
        headerViewHeight.constant = newValue
    }
    
    fileprivate func animateLayoutChanges() {
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func handlePanningForBodyView() {
        if isScrollView(view: tableview) {
            // assigning scrollview delegate
            //tableview.delegate = self
            //tableview.panGestureRecognizer.addTarget(self, action: #selector(viewPanned))
        }
    }
    
    fileprivate func isScrollView(view:UIView) -> Bool {
        return view.isKind(of: UIScrollView.self)
    }
}

extension ParalloxView:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "test \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ParalloxView:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var shouldBegin = true
        print("in pan delegate : \(tableview.contentOffset.y)")
        if isScrollView(view: tableview) {
            if tableview.contentOffset.y > 0 {
                print("inside para")
                //shouldBegin = false
            }
        }
        return shouldBegin
    }
}

extension ParalloxView:UIScrollViewDelegate {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //previousPoint = scrollView.contentOffset
//        var direction = ParalloxDirection.up
//        if scrollView.contentOffset.y <= 0 {
//            direction = .down
//        }
//        self.delegate?.paralloxEffectStarted(paralloxView: self, direction: direction)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let currentTouchPoint = scrollView.panGestureRecognizer.location(in: self)
//        var direction = ParalloxDirection.up
//        if scrollView.contentOffset.y <= 0 {
//            direction = .down
//            if scrollView.contentOffset.y < previousPoint.y {
//                //direction = .up
//                //scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x,y:0), animated: false)
//            }
//        } else if scrollView.contentOffset.y > 0 {
//            print("> 0 : \(scrollView.contentOffset.y) and previous : \(previousPoint.y)")
//        }
        let direction = getParalloxDirection(currentOffset: scrollView.contentOffset)
        if (bodyViewTopConstraint.constant > bodyViewMinValue) && (direction == .up) {
            let calculatedHeight = calculateNewValue(direction: direction, currentOffset: scrollView.contentOffset)
            updateBodyViewConstraints(newValue: calculatedHeight.bodyViewHeight)
            updateHeaderViewConstraints(newValue: calculatedHeight.headerViewHeight)
            animateLayoutChanges()
            scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x,y:0), animated: false)
        } else if (bodyViewTopConstraint.constant <= bodyViewMaxValue) && (direction == .down) && (scrollView.contentOffset.y <= 0){
            let calculatedHeight = calculateNewValue(direction: direction, currentOffset: scrollView.contentOffset)
            updateBodyViewConstraints(newValue: calculatedHeight.bodyViewHeight)
            updateHeaderViewConstraints(newValue: calculatedHeight.headerViewHeight)
            animateLayoutChanges()
            scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x,y:0), animated: false)
        }
        previousPoint = scrollView.contentOffset
        // Notify Holder
        // calculate percenteage
//        let percentage = (calculatedHeight.bodyViewHeight == 0) ? 0: (calculatedHeight.bodyViewHeight / bodyViewMaxValue)
//        self.delegate?.paralloxEffectProgress(paralloxView: self, progress: percentage, direction: direction)
        // update body view top constraints
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //let currentTouchPoint = scrollView.panGestureRecognizer.location(in: self)
        //previousPoint = scrollView.contentOffset
//        var direction = ParalloxDirection.up
//        if scrollView.contentOffset.y <= 0 {
//            direction = .down
//        }
//        self.delegate?.paralloxEffectEnded(paralloxView: self, direction: direction)
    }
    
}
