//
//  SwipeableView.swift
//  SwipeableView
//
//  MIT License
//
//  Copyright (c) 2020 Luca Iaconis. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

/// Protocol at which an object can conforms to, in order to be notified about the SwipeableView events
protocol SwipeableViewProtocol:class {
    
    /// Called when the Swipeable view did finish expanding
    /// - Parameter swipeableView: the sender swipeable view
    /// - Parameter previousState: the previous expanded state (true if was expanded, false otherwise)
    func swipeableViewDidExpand(swipeableView:SwipeableView, previousState:Bool)
    
    /// Called when the Swipeable view did finish collpasing
    /// - Parameter swipeableView: the sender swipeable view
    /// - Parameter previousState: the previous expanded state (true if was expanded, false otherwise)
    func swipeableViewDidCollapse(swipeableView:SwipeableView, previousState:Bool)
    
    /// Called while the user is swiping (pan gesture) the view
    /// - Parameter swipeableView: the sender swipeable view
    /// - Parameter percentage: the percentage from 0.0 (collapsed) to 1.0 (expanded), relative to the start/end of the flexibleLayout
    func swipeableViewDidPan(swipeableView:SwipeableView, percentage:CGFloat)
    
}

/// View which allows user to swipe the view from collapsed to full screen, showing a child view controller within it
class SwipeableView: UIView {
    
    //MARK: Public Properties
    
    /// Get/Set the expanded state of this view, with the default animation
    var isExpanded:Bool {
        set {
            self.expand(newValue, wasExpanded: self.isExpanded)
        }
        get {
            return self.expanded
        }
    }
    
    /// The swipeable child view representation of the external layout which will be affected by the expanding / collapsing of this view
    var flexibleLayout: SwipeableItemLayout = .init()
    
    /// If set to true, the pan gesture on the view will be inverted, affecting the `flexibleLayout` in the
    /// opposite direction of the current axis
    var isPanGestureInverted: Bool = false
    
    /// Set/Get the swipe indicator visibility, with the default animation
    ///
    /// If `isSwipeIndicatorVisible` is set to `true` when the SwipeableView is expanded and
    /// `hideIndicatorWhenExpanded` is `true`, then the swipe indicator won't be shown
    ///
    var isSwipeIndicatorVisible:Bool = true {
        didSet{
            guard self.isSwipeIndicatorVisible != oldValue else { return }
            if self.isSwipeIndicatorVisible, self.isExpanded, self.hideIndicatorWhenExpanded {
                self.showSwipeEdgeView( false, animated: false)
            } else {
                self.showSwipeEdgeView(self.isSwipeIndicatorVisible)
            }
        }
    }
    
    /// Set/Get the visibility of the rounded corners to this view.
    ///
    /// If `true`, the rounded corners are shown according with the current `indicatorPosition`
    var hasRoundedCorners:Bool = true {
        didSet {
            guard self.hasRoundedCorners != oldValue else { return }
            self.setupRoundedCorners()
        }
    }
    
    /// Indicates if the swipe indicator view should be visible when the Swipeable view is expanded
    ///
    /// If changed to true, while the Swipeable view is expanded, it will hide the indicator right away
    /// If changed to false, while the Swipeable view is expanded, it will show the indicator right away
    ///
    var hideIndicatorWhenExpanded:Bool = false {
        didSet{
            guard self.hideIndicatorWhenExpanded != oldValue else { return }
            if self.isExpanded, self.hideIndicatorWhenExpanded {
                self.showSwipeEdgeView( false, animated: false)
            } else {
                self.showSwipeEdgeView( self.isSwipeIndicatorVisible , animated: false)
            }
        }
    }
    
    /// Get/Set the swipe indicator view position for this SwipeableView
    ///
    /// When this property changes, if the `hasRoundedCorners` is `true`, then also the corner edges will be
    /// updated as well, according with the new `indicatorPosition` value
    ///
    var indicatorPosition: SwipeableView.IndicatorPosition = .top {
        didSet{
            // keep the reference to any existing child view container
            let currentChildViewContainer = self.childViewContainer
            // remove the existing swipe edge view and recreate it completely
            self.swipeEdgeView?.removeFromSuperview()
            self.setupSwipeEdgeView()
            // apply back the existing child view container, based on the new swipe edge
            self.setupChildViewContainer(currentChildViewContainer)
            // update the rounded corners if needed
            self.setupRoundedCorners()
        }
    }
    
    /// The default edge view indicator colors
    static let defaultIndicatorColors:(UIColor,UIColor) = (UIColor(white: 0.95, alpha: 1.0), .lightGray)
    
    /// Get/set the color for the indicator edge view and the bar color within the indicator view (as tuple)
    var indicatorColors:(UIColor,UIColor) = SwipeableView.defaultIndicatorColors {
        didSet{
            self.swipeEdgeView?.backgroundColor = self.indicatorColors.0
            self.swipeEdgeBarView?.backgroundColor = self.indicatorColors.1
        }
    }
    
    /// Indicates if the shown child view should have the user interaction enabled only when
    /// the SwipeableView is fully expanded
    ///
    var childViewInteractionOnExpandedOnly:Bool = true {
        didSet{
            self.childViewContainer?.isUserInteractionEnabled = self.isChildViewInteractionAllowed
        }
    }
    
    /// Inidcates if the swipeable view should detect any child view which is subclass of UIScrollView.
    ///
    /// If true, it detects and keeps his weak reference in the property `coordinatedScrollView` as soon as
    /// the user touch the SwipeableView and therefore invokes his hitTest(:) method
    var autoDetectScrollViews:Bool = false
    
    /// Indicates if any referred `coordinatedScrollView` should have the scrolling coordinated along with
    /// the swipeable view pan gesture recognizer.
    ///
    /// This features relies on the correct setup of the `indicatorPosition`, and can work with all 4 the positions.
    ///
    /// For example, a swipeable view which expands from bottom to top, should have the `indicatorPosition` set to
    /// `.top` ( even if `isSwipeIndicatorVisible` is set to `false` )
    var handleCoordinatedScrollView:Bool = false
    
    /// Weak reference to any scrollview (scrollview, table view, collection view,...) for which his scrolling via
    /// pan gesture recognizer should be currently coordinated along with the SwipableView pan gesture recognizer.
    /// The scrolling coordination will happen only if the property `handleCoordinatedScrollView` is set to `true`
    ///
    /// If `autoDetectScrollViews` is set to `true`, this property will be automatically set, if any scrollview
    /// within the SwipeableView or his child views will be detected.
    /// If `autoDetectScrollViews` is set to `false`, you can still set this property manually based on your needs
    ///
    weak var coordinatedScrollView:UIScrollView? {
        didSet{
            if oldValue != self.coordinatedScrollView {
                oldValue?.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(sender:)))
                self.coordinatedScrollView?.panGestureRecognizer.addTarget(self, action: #selector(handlePan(sender:)))
                self.coordScrollInitOffset = .zero
                self.coordScrollInitiSize = .zero
            }
        }
    }
    
    /// The percentage threshold (from 0.0 to 1.0) used to detect when the swipeable view should expand above it,
    /// or collapse under it, when the user lift the finger from the screen
    var notchThreshold:CGFloat = 0.5
    
    /// The current swipe percentage from 0 to 1
    private(set) var currentPercentage:CGFloat = 0.0 {
        didSet {
            self.oldPercentage = oldValue
        }
    }
    
    /// The delegate object which gets notified from this Swipeable view
    weak var delegate:SwipeableViewProtocol?
    
    //MARK: Private Properties
    
    /// The default component animation duration
    private let animDuration:TimeInterval = 0.5
    
    /// List of extra animatable items which are animated along with the expand/collapse of this view
    private(set) var animatableItems: [SwipeableItem] = []
    
    /// The current expanded/collapsed state of the swipeable view
    private var expanded:Bool = false
    /// the swipe view which practically allows the user to swipe the view from collapsted to fullscreen
    private weak var swipeEdgeView:UIView?
    /// The thickness of the swipe view
    private let swipeEdgeViewThickness:CGFloat = 25.0
    /// The size of the swipe bar view inside the swipeEdgeView
    private let swipeEdgeBarViewSize = CGSize(width: 36.0, height: 5.0)
    /// Reference to the swipe view height constraint
    private weak var swipeViewThicknessConstraint: NSLayoutConstraint?
    /// Reference to the short bar indicator view contained into the swipeEdgeView
    private weak var swipeEdgeBarView:UIView?
    
    /// The view which will contain the actual child view
    private weak var childViewContainer:UIView?
    /// The view controller of which his view is currently shown within the containerChildView
    private weak var childVC:UIViewController?
    /// Indicates if the child view should have user interaction allowed with the current SwipeableView state
    private var isChildViewInteractionAllowed:Bool { !self.isExpanded && self.childViewInteractionOnExpandedOnly ? false : true  }
    
    /// The pan gesture recognizer used to swipe up and down the view
    private weak var panGesture:UIPanGestureRecognizer?
    
    /// The previous swipe percentage from 0 to 1
    private var oldPercentage:CGFloat = 0.0
    
    /// The velocity threshold in X and Y (as absolute values), used to identify whether the swipeable view
    /// should go straight to full expand/collapse when user lift the finger from screen.
    private let endVelocityThreshold = CGPoint(x: 100, y: 100)
    
    /// The initial `coordinatedScrollView` contentOffset
    private var coordScrollInitOffset:CGPoint = .zero
    
    /// The initial `coordinatedScrollView` contentSize (minus his size)
    private var coordScrollInitiSize:CGSize = .zero
    
    //MARK: View lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    //MARK: Public
    
    /// Shows the provided view controller as child, given the provided parent view controller
    ///
    /// Make sure this view is a child view of the provided parentVC.view
    ///
    /// Any previously shown child view will be removed before the new one being shown
    ///
    /// - Parameters:
    ///   - childVC: the view controller to be shown as child view into this component
    ///   - parentVC: the parent view controller which is attempting to show the child view
    func setChildView(childVC:UIViewController, parentVC:UIViewController) {
        guard let containerView = self.childViewContainer else { return }
        
        // remove existing child view controller
        self.removeChildView()
        
        // show the new child view controller
        parentVC.addChild(childVC)
        childVC.view.frame = containerView.bounds
        containerView.addSubview(childVC.view)
        childVC.didMove(toParent: parentVC)
        self.childVC = childVC
        containerView.isUserInteractionEnabled = self.isChildViewInteractionAllowed
    }
    
    /// Removes any attached child view from this view
    func removeChildView(){
        guard let child = self.childVC else { return }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    /// Expands/Collapses this SwipeableView
    /// - Parameters:
    ///   - expand: expands/collapses the view
    ///   - animated: animated or not
    func expand(_ expand:Bool, animated:Bool = true){
        self.expand(expand, wasExpanded: self.isExpanded, animated: animated)
    }
    
    /// Adds the provided animatable item to the list of animatable items
    /// - Parameter item: the animatable item to be added
    func addAnimatableItem(_ item:SwipeableItem) {
        // update the just added animatable item to the right percentage
        item.set(percentage: self.currentPercentage)
        // add to the animatable items
        self.animatableItems.append(item)
    }
    
    /// Removes all the animatable items from the list of animatable items
    func removeAllAnimatableItems() {
        self.animatableItems.removeAll()
    }
    
    //MARK: Private
    
    /// Performs the animation on the given blocks
    /// - Parameters:
    ///   - bouncing: whether a bouncing effect using spring animation should be used or not
    ///   - options: the animation options
    ///   - animations: the animation block to be performed
    ///   - completion: the completion block to be called once the animation is completed
    private func animate(bouncing:Bool = true, options:UIView.AnimationOptions = [.beginFromCurrentState,.curveEaseOut], animations: @escaping () -> Void, completion: ((Bool) -> ())? = nil){
        if bouncing {
            UIView.animate(withDuration: self.animDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: options, animations: animations, completion: completion)
        } else {
            UIView.animate(withDuration: self.animDuration, delay: 0, options: options, animations: animations, completion: completion)
        }
    }
    
}

//MARK: - Private Expand/Collapse methods
extension SwipeableView {
    
    /// Expands/Collapses this SwipeableView
    /// - Parameters:
    ///   - expand: expand/collapsed the view
    ///   - wasExpanded: the prevuous expanded state
    ///   - animated: animated or not
    private func expand(_ expand:Bool, wasExpanded:Bool, animated:Bool = true){
            
        // set the new expand/collapse flag
        self.expanded = expand
        
        // update the current percentage based on the expand/collapse state
        self.currentPercentage = expand ? 1.0 : 0.0
        
        // update the child view container user interaction state based on the expand/collapse, if requested
        if self.childViewInteractionOnExpandedOnly {
            self.childViewContainer?.isUserInteractionEnabled = expand
        }
        
        guard animated else {
            // hide/show the swipe view if needed
            if expand, self.hideIndicatorWhenExpanded {
                self.showSwipeEdgeView(false, animated: false)
            } else if !expand {
                self.showSwipeEdgeView(self.isSwipeIndicatorVisible, animated: false)
            }
            // expand/collapse this Swipeable view
            self.flexibleLayout.set(expanded: expand)
            // prepare for expand/collapse all extra layouts
            self.expandAnimatableItems(expand)
            // notify the delegate
            if expand {
                self.delegate?.swipeableViewDidExpand(swipeableView: self, previousState: wasExpanded)
            } else {
                self.delegate?.swipeableViewDidCollapse(swipeableView: self, previousState: wasExpanded)
            }
            return
        }
        
        // hide/show the swipe view if needed
        if expand, self.hideIndicatorWhenExpanded {
            self.showSwipeEdgeView(false)
        } else if !expand {
            self.showSwipeEdgeView(self.isSwipeIndicatorVisible)
        }
        // animate the flexible layout and the extra animatable items
        self.animate(animations: {
            // expand/collapse the flexible layout, in order to affect this SwipeableView
            self.flexibleLayout.set(expanded: expand)
            // expand/collapse the animatable items accordingly
            self.expandAnimatableItems(expand)
        }) { [weak self] (_) in
            guard let self = self else { return }
            // notify the delegate
            if expand {
                self.delegate?.swipeableViewDidExpand(swipeableView: self, previousState: wasExpanded)
            } else {
                self.delegate?.swipeableViewDidCollapse(swipeableView: self, previousState: wasExpanded)
            }
        }
    }
    
    /// Shows/ hides the swipe edge view, adapting the layout of the component
    /// - Parameters:
    ///   - show: show/hide the swipe indicator bar
    ///   - animated: animated or not
    private func showSwipeEdgeView(_ show:Bool, animated:Bool = true){
        guard animated else {
            self.swipeViewThicknessConstraint?.constant = show ? self.swipeEdgeViewThickness : 0.0
            self.swipeEdgeView?.alpha = show ? 1.0 : 0.0
            return
        }
        self.swipeViewThicknessConstraint?.constant = show ? self.swipeEdgeViewThickness : 0.0
        // animate
        self.animate(animations: {
            self.layoutIfNeeded()
            self.swipeEdgeView?.alpha = show ? 1.0 : 0.0
        })
    }
    
    /// This method toggle the extra animatable items, from the start to end or vice versa
    /// - Parameter expand: if true constant will go from start to end, otherise from end to start
    private func expandAnimatableItems(_ expand:Bool) {
        // prunes all the extra animatable items which are flagged as no longer valid
        self.animatableItems.removeAll(where: { $0.isValid == false })
        guard !self.animatableItems.isEmpty else { return }
        self.animatableItems.forEach { $0.set(expanded: expand) }
    }
    
    /// This method applies the provided relative percentage to all the extra animatable items
    /// - Parameter percentage: the percentge to be applied to all the extra animatable items
    private func expandAnimatableItems(withPercentage percentage:CGFloat ){
        guard !self.animatableItems.isEmpty else { return }
        guard percentage >= 0.0 else { return }
        self.animatableItems.forEach { $0.set(percentage: percentage) }
    }
}

//MARK: - Private pan gesture methods

extension SwipeableView {
    
    @objc private func handlePan(sender:UIPanGestureRecognizer){
        
        // Prevent the handling of the pan gesture if coming from the coordinated scroll view and
        // the handleCoordinatedScrollView is false
        guard self.handleCoordinatedScrollView || sender != self.coordinatedScrollView?.panGestureRecognizer else {
            return
        }
        
        guard let referredView = self.superview else { return }
        guard let flexLayout = self.flexibleLayout.layout else { return }
        
        switch sender.state {
        case .began:
            // If the sender gesture comes from the coordinated scrollview
            if let scrollView = self.coordinatedScrollView, sender == scrollView.panGestureRecognizer {
                self.coordScrollInitOffset = scrollView.contentOffset
                self.coordScrollInitiSize = CGSize(width: scrollView.contentSize.width - scrollView.bounds.width,
                                                 height: scrollView.contentSize.height - scrollView.bounds.height)
            }
        case .changed:
            let translation = self.translation(for: sender, in: referredView)
            let newLayoutConstant = flexLayout.constant + (self.flexibleLayout.isVerticalAxis ? translation.y : translation.x) * (self.isPanGestureInverted ? -1 : 1)
            
            // apply the change to the layout
            let didApply = self.flexibleLayout.set(value: newLayoutConstant)
            
            let newPercentage = self.flexibleLayout.percentage
            
            // apply the relative change to all the extra animatable items
            self.expandAnimatableItems(withPercentage: newPercentage)
            
            // notify the delegate about the pan change if needed
            if newPercentage != self.currentPercentage {
                self.delegate?.swipeableViewDidPan(swipeableView: self, percentage: newPercentage)
            }
            
            // update the current percentage if there's an actual translation in the change state
            if translation != .zero {
                self.currentPercentage = newPercentage
            }
            
            // reset the translation if value was set was successful (therefore, the constant was in the range)
            self.finalizeStateChanged(for: sender, didApply: didApply, referredView: referredView)

        case .ended, .cancelled:
            self.finalizeStateEnded(for: sender, referredView: referredView)
        default:
            break
        }
    }
    
    /// Returns the translation offset on the provided gesture recognizer in the given view
    ///
    /// It handles the both the default SwipeableView pan gesture, and the coordinated scroll view if needed
    /// - Parameters:
    ///   - sender: the gesture recognizer
    ///   - view: the referrred view
    /// - Returns: the resulting translation offset to be applied
    private func translation(for sender:UIPanGestureRecognizer,in view:UIView) -> CGPoint {
        var translation = sender.translation(in: view)
        if let scrollView = self.coordinatedScrollView, sender == scrollView.panGestureRecognizer {
            if self.isExpanded {
                switch self.indicatorPosition {
                case .top:
                    translation.y -= self.coordScrollInitOffset.y
                case .bottom:
                    translation.y += (self.coordScrollInitiSize.height - self.coordScrollInitOffset.y)
                case .left:
                    translation.x -= self.coordScrollInitOffset.x
                case .right:
                    translation.x += (self.coordScrollInitiSize.width - self.coordScrollInitOffset.x)
                }
            }
            return translation
        } else {
            return translation
        }
    }
    
    /// Finalizes the gesture state `changed` iteration
    /// - Parameters:
    ///   - sender: the gesture recognizer
    ///   - didApply: indicates if the flexibleLayout set was successful (meaning, if the value was in range)
    ///   - referredView: the referred view to be considered with the gesture recognizer
    private func finalizeStateChanged(for sender:UIPanGestureRecognizer, didApply:Bool, referredView:UIView) {
        if didApply {
            if let scrollView = self.coordinatedScrollView, sender == scrollView.panGestureRecognizer {
                let cOff = scrollView.contentOffset
                let cSize = CGSize(width: scrollView.contentSize.width - scrollView.bounds.width,
                                     height: scrollView.contentSize.height - scrollView.bounds.height)
                if self.isExpanded {
                    switch self.indicatorPosition {
                    case .top:
                        scrollView.contentOffset = CGPoint(x: cOff.x, y: 0)
                    case .bottom:
                        scrollView.contentOffset = CGPoint(x: cOff.x, y: cSize.height)
                    case .left:
                        scrollView.contentOffset = CGPoint(x: 0, y: cOff.y)
                    case .right:
                        scrollView.contentOffset = CGPoint(x: cSize.width, y: cOff.y)
                    }
                }
                if [.top,.left].contains(self.indicatorPosition){
                    self.coordScrollInitOffset = .zero
                }
            }
            sender.setTranslation(.zero, in: referredView)
        }
    }
    
    /// Finalizes the gesture state `ended` iteration
    /// - Parameters:
    ///   - sender: the gesture recognizer
    ///   - referredView: the referred view to be considered with the gesture recognizer
    private func finalizeStateEnded(for sender:UIPanGestureRecognizer, referredView:UIView) {
        
        let endVelocity = sender.velocity(in: referredView)
        let exceedStates = (abs(endVelocity.x) > abs(endVelocityThreshold.x), abs(endVelocity.y) > abs(endVelocityThreshold.y))
        let expandCollapseToEnd:Bool = self.flexibleLayout.isVerticalAxis && exceedStates.1 || !self.flexibleLayout.isVerticalAxis && exceedStates.0
        if expandCollapseToEnd, self.oldPercentage != self.currentPercentage {
             // complete the expand/collapse transition according with the percentage direction (growing or not)
            self.isExpanded = self.oldPercentage < self.currentPercentage
        } else {
            // complete the expand/collapse transition according with the current percentage vs notch threshold
            self.isExpanded = self.currentPercentage >= self.notchThreshold
        }
        
        sender.setTranslation(.zero, in: referredView)
        // reset the coordinated scrollview initial offset anf content size on state ended in any case
        self.coordScrollInitOffset = .zero
        self.coordScrollInitiSize = .zero
    }
    
}

//MARK: - Private hit test method for auto detecting child scrollviews
extension SwipeableView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if autoDetectScrollViews is false, handle hitTest with his default behavior
        guard self.autoDetectScrollViews else { return super.hitTest(point, with: event) }
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        guard hitView != self else { return hitView }
        
        // look for the first available scrollview view from the hit view
        if let scrollView = self.find(type: UIScrollView.self, from: hitView, limit: self), self.coordinatedScrollView != scrollView {
            self.coordinatedScrollView = scrollView
        }
        return hitView
    }
    
    /// Find the first view/superview from the provided viewm which conforms with the given type
    /// - Parameters:
    ///   - type: the view type to search for
    ///   - view: the start view, from which going up through superviews
    ///   - limit: the limit view that, if reached, should stop the search and return nil
    /// - Returns: the match view, or nil if not found
    private func find<T:UIResponder>(type:T.Type, from view:UIView, limit:UIView) -> T? {
        guard view != limit else { return nil }
        if let v = view as? T { return v }
        guard let superview = view.superview else { return nil }
        guard let matchView = superview as? T else { return self.find(type: type, from: superview, limit: limit) }
        return matchView
    }
}

//MARK: - Private setup view methods
extension SwipeableView {
    
    /// Setup the layout and ui for the entire swipeable view
    private func setup() {
        self.clipsToBounds = true
        self.setupRoundedCorners()
        self.setupSwipeEdgeView()
        self.setupChildViewContainer()
        self.setupPanGesture()
    }
    
    /// Setup/Updates the corner radius of this view based on the `indicatorPosition` property
    private func setupRoundedCorners(){
        guard self.hasRoundedCorners else {
            self.layer.cornerRadius = 0.0
            return
        }
        self.indicatorPosition.applyCornerRadius(to: self, radius: self.swipeEdgeViewThickness / 2)
    }
    
    /// Setup the layout and ui for swipe edge view
    private func setupSwipeEdgeView() {
        
        // setup the swipe view layout and ui
        let swipeEdgeView = UIView()
        swipeEdgeView.clipsToBounds = true
        swipeEdgeView.backgroundColor = self.indicatorColors.0
        swipeEdgeView.alpha = self.isSwipeIndicatorVisible ? (self.isExpanded && self.hideIndicatorWhenExpanded ? 0.0 : 1 ) : 0.0
        self.addSubview(swipeEdgeView)
        
        swipeEdgeView.translatesAutoresizingMaskIntoConstraints = false
        self.swipeViewThicknessConstraint = self.indicatorPosition.layoutSwipeEdgeView(swipeEdgeView, parentView: self, thickness: swipeEdgeViewThickness)
        self.swipeEdgeView = swipeEdgeView
        
        // setup the swipe indicator view layout and ui
        let swipeIndicatorView = UIView()
        swipeIndicatorView.backgroundColor = self.indicatorColors.1
        swipeIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        swipeIndicatorView.layer.cornerRadius = swipeEdgeBarViewSize.height / 2
        swipeEdgeView.addSubview(swipeIndicatorView)
        self.indicatorPosition.layoutEdgeIndicatorView(swipeIndicatorView,
                                                       swipeEdgeView: swipeEdgeView,
                                                       indicatorSize: swipeEdgeBarViewSize)
        self.swipeEdgeBarView = swipeIndicatorView
    }
    
    /// Setup the child view container
    /// - Parameter existingChildViewContainer: if provided, refers to the existing child view container, and it will be used instead of creating a new one
    private func setupChildViewContainer(_ existingChildViewContainer:UIView? = nil) {
        
        guard let swipeV = self.swipeEdgeView else { return }
        
        let childViewContainer:UIView
        if let existingChildViewContainer = existingChildViewContainer {
            // by removing it from the superview, all the existing layouts to it will be removed as well
            existingChildViewContainer.removeFromSuperview()
            childViewContainer = existingChildViewContainer
        } else {
            childViewContainer = UIView()
            childViewContainer.translatesAutoresizingMaskIntoConstraints = false
        }
        self.addSubview(childViewContainer)
        self.indicatorPosition.layoutChildViewContainer(childViewContainer, parentView: self, swipeEdgeView: swipeV)
        self.childViewContainer = childViewContainer
    }
    
    /// Setup the pan gesture recognizer, for expanding/collapsing the view with the pan gesture
    private func setupPanGesture(){
        let pGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(pGesture)
        self.panGesture = pGesture
    }
    
}

//MARK: - IndicatorPosition enum definition
extension SwipeableView {
    
    /// The possible position options for the Swipeable view indicator
    enum IndicatorPosition {
        case top
        case bottom
        case left
        case right
        
        /// Applies the corner radius to the provided view, with the given radius, accordinb
        /// with this indicator position
        /// - Parameters:
        ///   - view: the view at which the corner radius need to be applied
        ///   - radius: the radius to be used for the corners
        fileprivate func applyCornerRadius(to view:UIView, radius:CGFloat) {
            view.layer.cornerRadius = radius
            switch self {
            case .top:
                view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            case .bottom:
                view.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
            case .left:
                view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
            case .right:
                view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
            }
        }
        
        /// Applies the layout to the swipe edge view, based on this indicator position
        /// - Parameters:
        ///   - swipeEdgeView: the swipe edge view to be layout
        ///   - parentView: the parent view at which the swipe edge should refer
        ///   - thickness: the expected thickness of the swipeEdgeView
        /// - Returns: the layout constraint which represent the thickness for the swipe edge view, given this indicator positon
        fileprivate func layoutSwipeEdgeView(_ swipeEdgeView:UIView, parentView:UIView, thickness:CGFloat)->NSLayoutConstraint {
            let swipeViewContrThickness:NSLayoutConstraint
            switch self {
            case .top,.bottom:
                swipeEdgeView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
                swipeEdgeView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
                if self == .top {
                    swipeEdgeView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
                }else {
                    swipeEdgeView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
                }
                swipeViewContrThickness = swipeEdgeView.heightAnchor.constraint(equalToConstant: thickness)
            case .left,.right:
                swipeEdgeView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
                swipeEdgeView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
                if self == .left{
                    swipeEdgeView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
                }else {
                    swipeEdgeView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
                }
                swipeViewContrThickness = swipeEdgeView.widthAnchor.constraint(equalToConstant: thickness)
            }
            swipeViewContrThickness.isActive = true
            return swipeViewContrThickness
        }
        
        /// Applies the layout to the swipe indicator view within the swipe edge view, bases on this indicator position
        /// - Parameters:
        ///   - swipeIndicatorView: the indicator view to be layout
        ///   - swipeEdgeView: the parent edge view at which the indicator should refer
        ///   - indicatorSize: the expected swipe indicator view size
        fileprivate func layoutEdgeIndicatorView(_ swipeIndicatorView:UIView, swipeEdgeView:UIView, indicatorSize:CGSize) {
            swipeIndicatorView.centerYAnchor.constraint(equalTo: swipeEdgeView.centerYAnchor).isActive = true
            swipeIndicatorView.centerXAnchor.constraint(equalTo: swipeEdgeView.centerXAnchor).isActive = true
            switch self {
            case .top,.bottom:
                swipeIndicatorView.widthAnchor.constraint(equalToConstant: indicatorSize.width).isActive = true
                swipeIndicatorView.heightAnchor.constraint(equalToConstant: indicatorSize.height).isActive = true
            case .left,.right:
                swipeIndicatorView.widthAnchor.constraint(equalToConstant: indicatorSize.height).isActive = true
                swipeIndicatorView.heightAnchor.constraint(equalToConstant: indicatorSize.width).isActive = true
            }
        }
        
        /// Applies the layout to the child view container, bases on this indicator position
        /// - Parameters:
        ///   - childViewContainer: the child view container to be layout
        ///   - parentView: the parent view of the child view container to be referred
        ///   - swipeEdgeView: the swipe edge view to be considered during the layout
        fileprivate func layoutChildViewContainer(_ childViewContainer:UIView, parentView:UIView, swipeEdgeView:UIView) {
            switch self {
            case .top,.bottom:
                childViewContainer.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
                childViewContainer.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
                childViewContainer.topAnchor.constraint(equalTo: (self == .top ? swipeEdgeView.bottomAnchor : parentView.topAnchor) ).isActive = true
                childViewContainer.bottomAnchor.constraint(equalTo: (self == .top ? parentView.bottomAnchor : swipeEdgeView.topAnchor)).isActive = true
            case .left,.right:
                childViewContainer.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
                childViewContainer.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
                childViewContainer.leadingAnchor.constraint(equalTo: (self == .left ? swipeEdgeView.trailingAnchor : parentView.leadingAnchor)).isActive = true
                childViewContainer.trailingAnchor.constraint(equalTo: (self == .left ? parentView.trailingAnchor : swipeEdgeView.leadingAnchor)).isActive = true
            }
        }
    }
    
}
