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
	
	//MARK: - initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		//createViews()
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		//createViews()
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
		return (calculatedHeaderViewHeight,calculatedTopConstraint)
	}
	// MARK: - Helpers
	func setupViews() {
		//tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		//handlePanningForBodyView()
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
		UIView.animate(withDuration: 0.1) {
			self.layoutIfNeeded()
		}
	}
	
	fileprivate func isScrollView(view:UIView) -> Bool {
		return view.isKind(of: UIScrollView.self)
	}
	
	// update view position
	func updateSubViewsPosition(calculatedHeight:(headerViewHeight:CGFloat,bodyViewHeight:CGFloat)) {
		updateBodyViewConstraints(newValue: calculatedHeight.bodyViewHeight)
		updateHeaderViewConstraints(newValue: calculatedHeight.headerViewHeight)
		animateLayoutChanges()
	}
	
	/// scrollview did Scroll method invoke this method to acheive paralox effect
	///
	/// - Parameter scrollView: scrollview of which scrolling handled
	func scrollingHappening(scrollView:UIScrollView) {
		let direction = getParalloxDirection(currentOffset: scrollView.contentOffset)
		let calculatedHeight = calculateNewValue(direction: direction, currentOffset: scrollView.contentOffset)
		if (bodyViewTopConstraint.constant > bodyViewMinValue) && (direction == .up) && (scrollView.contentOffset.y >= 0){
			updateSubViewsPosition(calculatedHeight: calculatedHeight)
			scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x,y:0), animated: false)
			// Notify Holder
			// calculate percenteage
			let percentage = (calculatedHeight.bodyViewHeight == 0) ? 0: (calculatedHeight.bodyViewHeight / bodyViewMaxValue)
			self.delegate?.paralloxEffectProgress(paralloxView: self, progress: percentage, direction: direction)
		} else if (bodyViewTopConstraint.constant <= bodyViewMaxValue) && (direction == .down) && (scrollView.contentOffset.y <= 0){
			updateSubViewsPosition(calculatedHeight: calculatedHeight)
			if bodyViewTopConstraint.constant != bodyViewMaxValue {
				scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x,y:0), animated: false)
				// Notify Holder
				// calculate percenteage
				let percentage = (calculatedHeight.bodyViewHeight == 0) ? 0: (calculatedHeight.bodyViewHeight / bodyViewMaxValue)
				self.delegate?.paralloxEffectProgress(paralloxView: self, progress: percentage, direction: direction)
			}
		}
		previousPoint = scrollView.contentOffset
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
