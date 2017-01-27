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
	@IBOutlet weak var bodyViewTopConstraint: NSLayoutConstraint?
	@IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint?
	/// for touch location tracking
	fileprivate var previousPoint = CGPoint(x: 0, y: 0)
	/// Min , Max Values for Top Constraints to restrict beyond that point
	/// Body view min value, exposed, will be set by external classes
	var minTopPositionOfBodyView = CGFloat(0)
	var minHeightOfHeaderView = CGFloat(0)
	private var maxTopPositionOfBodyView = CGFloat(0) // be updated once constraints set
	private var maxHeightOfHeaderView = CGFloat(0) // be updated once constraints set
	/// delegate instance for notification
	public weak var delegate:ParalloxViewDelegate?
	
	//MARK: - Override methods
	override func layoutSubviews() {
		super.layoutSubviews()
		// initial value for contraint may be 500 set by Xcode byDefault
		if maxTopPositionOfBodyView == 0 || maxTopPositionOfBodyView == 500 {
			if let height = self.delegate?.customHeight?(for: self) {
				bodyViewTopConstraint?.constant = height
			}
			if let bodyViewTop = bodyViewTopConstraint?.constant {
				maxTopPositionOfBodyView = bodyViewTop
			}
		}
		if maxHeightOfHeaderView == 0 || maxHeightOfHeaderView == 500 {
			if let height = self.delegate?.customHeight?(for: self) {
				headerViewHeightConstraint?.constant = height
			}
			if let headerHeight = headerViewHeightConstraint?.constant {
				maxHeightOfHeaderView = headerHeight
			}
		}
	}
	
	// MARK: - Public Methods
	/// scrollview did Scroll method invoke this method to acheive paralox effect
	///
	/// - Parameter scrollView: scrollview of which scrolling handled
	public func scrolled(scrollView:UIScrollView) {
		let direction = getParalloxDirection(currentOffset: scrollView.contentOffset)
		let calculatedPosition = calculateNewPosition(direction: direction, currentOffset: scrollView.contentOffset)
		if ((bodyViewTopConstraint?.constant)! > minTopPositionOfBodyView) && (direction == .up) && (scrollView.contentOffset.y >= 0){
			// set content offset to 0 to prevent scrolling
			scrollView.contentOffset = CGPoint(x:scrollView.contentOffset.x,y:0)
			// Place Views
			placeViews(at: calculatedPosition,animated: false)
		} else if (direction == .down) && (scrollView.contentOffset.y <= 0){
			// set content offset to 0 to prevent scrolling
			scrollView.contentOffset = CGPoint(x:scrollView.contentOffset.x,y:0)
			// Place Views
			placeViews(at: calculatedPosition,animated: false)
		}
		previousPoint = scrollView.contentOffset
	}
	
	/// Method to be called after scrolling stops to place view in required place
	/// @discuission, best place to be called in scrollviewDidEndDragging,ScrollviewDidEndDecelarate
	/// - Parameter offSet: current offSet of scrollview
	public func scrollDidStopped(at offSet:CGPoint) {
		let direction = getParalloxDirection(currentOffset: offSet)
		var calculatedPosition = calculateNewPosition(direction: direction, currentOffset: offSet)
		if calculatedPosition.bodyViewTopPosition > maxTopPositionOfBodyView{
			calculatedPosition.bodyViewTopPosition = maxTopPositionOfBodyView
			calculatedPosition.headerViewHeight = maxHeightOfHeaderView
		}
		// Place Views
		placeViews(at: calculatedPosition, animated: true)
	}
	
	// MARK: - Helpers
	
	/// Sending Event to external classes with percentage Calculated
	///
	/// - Parameter calculatedHeight: calculated Height Informations
	private func calculatePercentageAndSendEvent(calculatedPosition:(headerViewHeight:CGFloat,bodyViewTopPosition:CGFloat)){
		// calculate percentage
		let percentage = ((calculatedPosition.bodyViewTopPosition - minTopPositionOfBodyView) / maxTopPositionOfBodyView)
		self.delegate?.paralloxEffectProgress(paralloxView: self, progress: percentage)
	}
	/// Place view at specified position
	///
	/// - Parameters:
	///   - position: position to which the view to be placed
	///   - animated: flag to indicate animated movement
	///   - duration: duration in which animation happens
	private func placeViews(at position:(headerViewHeight:CGFloat,bodyViewTopPosition:CGFloat), animated:Bool = true, duration:TimeInterval = 0.3){
		// update views position
		updateSubViewsPosition(calculatedPosition: position,duration: duration,animated: animated)
		// calculate percentage and Send Notification
		calculatePercentageAndSendEvent(calculatedPosition: position)
	}
	/// calculate New Position
	private func calculateNewPosition(direction:ParalloxDirection, currentOffset:CGPoint) -> (headerViewHeight:CGFloat,bodyViewTopPosition:CGFloat){
		// get difference value
		var difference = CGFloat(0)
		if currentOffset.y != difference {
			difference = abs(previousPoint.y - currentOffset.y)
		}
		// calculate Header Height & Body Top constraint based on direction of scrolling
		var calculatedTopConstraint = CGFloat(0)
		var calculatedHeaderViewHeight = CGFloat(0)
		if  direction == .down {
			if let bodyViewTopValue = bodyViewTopConstraint?.constant,
				let headerViewHeightValue = headerViewHeightConstraint?.constant {
				calculatedTopConstraint =  bodyViewTopValue + difference
				calculatedHeaderViewHeight =  headerViewHeightValue + difference
			}
			
		} else {
			
			if let bodyViewTopValue = bodyViewTopConstraint?.constant,
				let headerViewHeightValue = headerViewHeightConstraint?.constant {
				calculatedTopConstraint = bodyViewTopValue - difference
				calculatedHeaderViewHeight = headerViewHeightValue - (difference*0.5)
			}
			if calculatedTopConstraint < minTopPositionOfBodyView {
				calculatedTopConstraint = minTopPositionOfBodyView
			}
			if calculatedHeaderViewHeight < minHeightOfHeaderView {
				calculatedHeaderViewHeight = minHeightOfHeaderView
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
		bodyViewTopConstraint?.constant = newValue
	}
	
	/// Update Header view height
	///
	/// - Parameter newValue: newValue to be updated
	private func updateHeaderViewConstraints(newValue:CGFloat) {
		headerViewHeightConstraint?.constant = newValue
	}
	
	/// Layout the views with animation
	private func performLayoutChanges(with duration:Double = 0.0, animated:Bool = false) {
		if animated {
			UIView.animate(withDuration: duration) {
				self.layoutIfNeeded()
			}
		} else {
			self.layoutIfNeeded()
		}
		
	}
	
	/// update view position
	private func updateSubViewsPosition(calculatedPosition:(headerViewHeight:CGFloat,bodyViewTopPosition:CGFloat),duration:Double = 0.0,animated:Bool = false) {
		updateBodyViewConstraints(newValue: calculatedPosition.bodyViewTopPosition)
		updateHeaderViewConstraints(newValue: calculatedPosition.headerViewHeight)
		performLayoutChanges(with: duration, animated: animated)
	}
}

