//
//  ParalloxView.swift
//  ParalloxEffectSample
//
//  Created by Muthuraj on 22/11/16.
//  Copyright © 2016 Muthuraj. All rights reserved.
//

import UIKit

protocol ParalloxViewDelegate:class {
    func paralloxEffectProgress(paralloxView:ParalloxView,progress:Double, direction:ParalloxDirection)
    func paralloxEffectStarted(paralloxView:ParalloxView, direction:ParalloxDirection)
    func paralloxEffectEnded(paralloxView:ParalloxView, direction:ParalloxDirection)
}

public enum ParalloxDirection {
    case top
    case bottom
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
    private var previousPoint = CGPoint(x: 0, y: 0)
    // Min , Max Values for Top Constraints to restrict beyond that point
    private var bodyViewMinValue = CGFloat(0)
    private var headerViewMinValue = CGFloat(0)
    private var bodyViewMaxValue = CGFloat(0) // be updated once constraints set
    private var headerViewMaxValue = CGFloat(0) // be updated once constraints set
    // delegate instance for notification
    public weak var delegate:ParalloxViewDelegate?
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
        if isScrollView(view: tableview) {
            if tableview.contentOffset.y <= 0 {
                // disable scrolling to avoid scrlling during panning
                tableview.isScrollEnabled = false
                let direction = getPanningDirection(sender)
                let velocity = sender.velocity(in: self)
                var paralloxDirection:ParalloxDirection?
                if direction == .top {
                    paralloxDirection = .top
                } else if direction == .bottom {
                    paralloxDirection = .bottom
                }
                switch sender.state {
                case .began:
                    if let pxDirection = paralloxDirection {
                        self.delegate?.paralloxEffectStarted(paralloxView: self, direction: pxDirection)
                    }
                    let currentLocation = sender.location(in: self)
                    previousPoint = currentLocation
                    break
                case .changed:
                    let currentLocation = sender.location(in: self)
                    let difference = abs(previousPoint.y - currentLocation.y)
                    var calculatedTopConstraint = CGFloat(0)
                    print("velocity : \(velocity)")
                    switch  direction {
                    case .left:
                        break
                    case .right:
                        break
                    case .top:
                        calculatedTopConstraint = bodyViewTopConstraint.constant - difference//previousPoint.y+velocity.y
                        var calculatedHeaderViewHeight = headerViewHeight.constant - (difference*0.5)
                        previousPoint = currentLocation
                        print("Top : calculated : \(calculatedTopConstraint)")
                        if calculatedTopConstraint < bodyViewMinValue {
                            print("inside Top : calculated : \(calculatedTopConstraint)")
                            calculatedTopConstraint = bodyViewMinValue
                        }
                        if calculatedHeaderViewHeight < headerViewMinValue {
                            calculatedHeaderViewHeight = headerViewMinValue
                        }
                        //                if calculatedHeaderViewHeight > headerViewMaxValue {
                        //                    calculatedHeaderViewHeight = headerViewMaxValue
                        //                }
                        
                        
                        // update body view top constraints
                        updateBodyViewConstraints(newValue: calculatedTopConstraint)
                        updateHeaderViewConstraints(newValue: calculatedTopConstraint/2)
                        animateLayoutChanges()
                        break
                    case .bottom:
                        calculatedTopConstraint = bodyViewTopConstraint.constant + difference//previousPoint.y+velocity.y
                        var calculatedHeaderViewHeight = headerViewHeight.constant + (difference*0.5)
                        previousPoint = currentLocation
                        print("bottom : calculated : \(calculatedTopConstraint)")
                        if calculatedTopConstraint > bodyViewMaxValue {
                            print("inside bottom : calculated : \(calculatedTopConstraint) and Max : \(bodyViewMaxValue)")
                            calculatedTopConstraint = bodyViewMaxValue
                        }
                        if calculatedHeaderViewHeight > headerViewMaxValue {
                            calculatedHeaderViewHeight = headerViewMaxValue
                        }
                        // update body view top constraints
                        updateBodyViewConstraints(newValue: calculatedTopConstraint)
                        updateHeaderViewConstraints(newValue: calculatedTopConstraint/2)
                        animateLayoutChanges()
                        break
                    }
                    if let pxDirection = paralloxDirection {
                        self.delegate?.paralloxEffectProgress(paralloxView: self, progress: 0.0, direction: pxDirection)
                    }
                    break
                case .ended:
                    if let pxDirection = paralloxDirection {
                        self.delegate?.paralloxEffectEnded(paralloxView: self, direction: pxDirection)
                    }
                    if direction == .top || direction == .bottom {
                        var calculatedTopConstraint = CGFloat(0)
                        var calculatedHeaderViewHeight = CGFloat(0)
                        calculatedTopConstraint = bodyViewMaxValue
                        calculatedHeaderViewHeight = headerViewMaxValue
                        if direction == .top {
                            calculatedTopConstraint = bodyViewMinValue
                            calculatedHeaderViewHeight = headerViewMinValue
                        }
                        // update body view top constraints
                        updateBodyViewConstraints(newValue: calculatedTopConstraint)
                        updateHeaderViewConstraints(newValue: calculatedTopConstraint/2)
                        animateLayoutChanges()
                    }
                    break
                default:
                    break
                }
            } else {
                // reset scrolling
                tableview.isScrollEnabled = true
            }
        }
    }
    
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
    
    private func getScaleFactorForYAxis(currentPoint:CGPoint) {
        // have to consider only y coordinate
    }
    
    private func updateBodyViewConstraints(newValue:CGFloat) {
        bodyViewTopConstraint.constant = newValue
    }
    
    private func updateHeaderViewConstraints(newValue:CGFloat) {
        headerViewHeight.constant = newValue
    }
    
    private func animateLayoutChanges() {
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func handlePanningForBodyView() {
        if isScrollView(view: tableview) {
            tableview.panGestureRecognizer.addTarget(self, action: #selector(viewPanned))
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
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "test \(indexPath.row)"
        return cell
    }
}

extension ParalloxView:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var shouldBegin = true
        print("in pan delegate : \(tableview.contentOffset.y)")
        if isScrollView(view: tableview) {
            if tableview.contentOffset.y > 0 {
                print("inside para")
                shouldBegin = false
            }
        }
        return shouldBegin
    }
}
