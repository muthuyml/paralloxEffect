//
//  ParalloxView.swift
//  ParalloxEffectSample
//
//  Created by Muthuraj on 22/11/16.
//  Copyright © 2016 Muthuraj. All rights reserved.
//

import UIKit

@objc protocol ParalloxViewDelegate:NSObjectProtocol {
	func paralloxEffectProgress(paralloxView:ParalloxView,progress:CGFloat)
	@objc optional func customHeight(for ParalloxView:ParalloxView) -> CGFloat
}

fileprivate enum ParalloxDirection {
	case up
	case down
}

class ParalloxView: UIView {
	
	/// Animatable constraints
	@IBOutlet weak var bodyViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var headerViewHeight: NSLayoutConstraint!
	/// for touch location tracking
	fileprivate var previousPoint = CGPoint(x: 0, y: 0)
	/// Min , Max Values for Top Constraints to restrict beyond that point
	/// Body view min value, exposed, will be set by external classes
	var bodyViewMinValue = CGFloat(0)
	var headerViewMinValue = CGFloat(0)
	private var bodyViewMaxValue = CGFloat(0) // be updated once constraints set
	private var headerViewMaxValue = CGFloat(0) // be updated once constraints set
	/// delegate instance for notification
	public weak var delegate:ParalloxViewDelegate?
	
	//MARK: - initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: - Override methods
	override func layoutSubviews() {
		super.layoutSubviews()
		// initial value for contraint may be 500 set by Xcode byDefault
		if bodyViewMaxValue == 0 || bodyViewMaxValue == 500 {
			if let height = self.delegate?.customHeight?(for: self) {
				bodyViewTopConstraint.constant = height
			}
			bodyViewMaxValue = bodyViewTopConstraint.constant
		}
		if headerViewMaxValue == 0 || headerViewMaxValue == 500 {
			if let height = self.delegate?.customHeight?(for: self) {
				headerViewHeight.constant = height
			}
			headerViewMaxValue = headerViewHeight.constant
		}
	}
	
	// MARK: - Public Methods
	/// scrollview did Scroll method invoke this method to acheive paralox effect
	///
	/// - Parameter scrollView: scrollview of which scrolling handled
	public func scrolled(scrollView:UIScrollView) {
		let velocity = scrollView.panGestureRecognizer.velocity(in: self)
		let direction = getParalloxDirection(currentOffset: scrollView.contentOffset)
		let calculatedHeight = calculateNewPosition(direction: direction, currentOffset: scrollView.contentOffset)
		if (bodyViewTopConstraint.constant > bodyViewMinValue) && (direction == .up) && (scrollView.contentOffset.y >= 0){
			// calculate duration
			let duration = calculateDuration(with: velocity)
			// update views position
			updateSubViewsPosition(calculatedHeight: calculatedHeight,duration: duration)
			// set content offset to 0 to prevent scrolling
			scrollView.contentOffset = CGPoint(x:scrollView.contentOffset.x,y:0)
			// calculate percentage and Send Notification
			calculatePercentageAndSendEvent(calculatedHeight: calculatedHeight)
			
		} else if (bodyViewTopConstraint.constant < bodyViewMaxValue) && (direction == .down) && (scrollView.contentOffset.y <= 0){
			// calculate duration
			let duration = calculateDuration(with: velocity)
			// update views position
			updateSubViewsPosition(calculatedHeight: calculatedHeight,duration: duration)
			// set content offset to 0 to prevent scrolling
			scrollView.contentOffset = CGPoint(x:scrollView.contentOffset.x,y:0)
			// calculate percentage and Send Notification
			calculatePercentageAndSendEvent(calculatedHeight: calculatedHeight)
		}
		previousPoint = scrollView.contentOffset
	}
	
	public func scrollDidStopped(scrollView:UIScrollView) {

		let direction = getParalloxDirection(currentOffset: scrollView.contentOffset)
		var calculatedHeight = calculateNewPosition(direction: direction, currentOffset: scrollView.contentOffset)
		if calculatedHeight.bodyViewHeight > (bodyViewMaxValue*0.5){
			calculatedHeight.bodyViewHeight = bodyViewMaxValue
			calculatedHeight.headerViewHeight = headerViewMaxValue
		} else {
			calculatedHeight.bodyViewHeight = bodyViewMinValue
			calculatedHeight.headerViewHeight = headerViewMinValue
		}
		
		positionViews(at: calculatedHeight, animated: true)
	}
	
	// MARK: - Helpers
	
	private func calculatePercentageAndSendEvent(calculatedHeight:(headerViewHeight:CGFloat,bodyViewHeight:CGFloat)){
		// calculate percenteage
		let percentage = (calculatedHeight.bodyViewHeight == bodyViewMinValue) ? 0: (calculatedHeight.bodyViewHeight / bodyViewMaxValue)
		self.delegate?.paralloxEffectProgress(paralloxView: self, progress: (1-percentage))
	}
	
	private func calculateDuration(with velocity:CGPoint) -> TimeInterval {
		var duration = Double(bodyViewMaxValue/velocity.y)*0.5
		if duration > 0.02 {
			duration = 0.02
		}
		
		return duration
	}
	
	private func positionViews(at position:(headerViewHeight:CGFloat,bodyViewHeight:CGFloat), animated:Bool = true, duration:TimeInterval = 0.3){
		updateSubViewsPosition(calculatedHeight: position,duration: duration)
	}
	/// calculate New Position
	private func calculateNewPosition(direction:ParalloxDirection, currentOffset:CGPoint) -> (headerViewHeight:CGFloat,bodyViewHeight:CGFloat){
		// get difference value
		var difference = CGFloat(0)
		if currentOffset.y != difference {
			difference = abs(previousPoint.y - currentOffset.y)
		}
		// calculate Header Height & Body Top constraint based on direction of scrolling
		var calculatedTopConstraint = CGFloat(0)
		var calculatedHeaderViewHeight = CGFloat(0)
		if  direction == .down {
			calculatedTopConstraint = bodyViewTopConstraint.constant + difference
			calculatedHeaderViewHeight = headerViewHeight.constant + (difference*0.5)
//			if calculatedTopConstraint > bodyViewMaxValue {
//				calculatedTopConstraint = bodyViewMaxValue
//			}
//			if calculatedHeaderViewHeight > headerViewMaxValue {
//				calculatedHeaderViewHeight = headerViewMaxValue
//			}
			
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
	
	/// Get Parallox direction
	private func getParalloxDirection(currentOffset:CGPoint) -> ParalloxDirection{
		var direction = ParalloxDirection.down
		if previousPoint.y < currentOffset.y {
			direction = .up
		}
		return direction
	}
	
	/// update bodyView(scrollview) top constraint value
	///
	/// - Parameter newValue: newValue to be updated  000
	private func updateBodyViewConstraints(newValue:CGFloat) {
		bodyViewTopConstraint.constant = newValue
	}
	
	/// Update Header view height
	///
	/// - Parameter newValue: newValue to be updated
	private func updateHeaderViewConstraints(newValue:CGFloat) {
		headerViewHeight.constant = newValue
	}
	
	/// Layout the views with animation
	private func animateLayoutChanges(with duration:Double, animated:Bool) {
		if animated {
			UIView.animate(withDuration: duration) {
				self.layoutIfNeeded()
			}
		} else {
			self.layoutIfNeeded()
		}
		
	}
	
	/// update view position
	private func updateSubViewsPosition(calculatedHeight:(headerViewHeight:CGFloat,bodyViewHeight:CGFloat),duration:Double) {
		updateBodyViewConstraints(newValue: calculatedHeight.bodyViewHeight)
		updateHeaderViewConstraints(newValue: calculatedHeight.headerViewHeight)
		animateLayoutChanges(with: duration,animated: true)
	}
}

