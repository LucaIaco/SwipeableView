//
//  SwipeableItems.swift
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

/// Protocol at which an item should conforms to, in order to be interpolated/animated along with the SwipeableView
protocol SwipeableItem : class {
    
    /// Indicates if this item should keep being considered during the animations or should be removed.
    ///
    /// For example, if the weak referred external object (eg. view, layout,...) is no longer available,
    /// then this getter can return false and the SwipeableView will consequently prune it away
    var isValid:Bool { get }
    
    /// applies the necessary changes to the animatable properties based on the expanded/collapsed state
    ///
    /// - Parameter expanded: configures the animatable component as expanded or collapsed
    func set(expanded: Bool)
    
    /// Changes the animatable item applying the provided percentage, relative to the lower/upper bounds values
    /// - Parameter percentage: the percentge to be applied (from 0.0 to 1.0)
    ///
    /// - percentage 0.0 is the lower bound value
    /// - percentage 1.0 is the upper bound value
    func set(percentage:CGFloat)
}

extension SwipeableItem {
    
    /// Returns the float value from the provided percentage relative to the two start/end bounds
    /// - Parameters:
    ///   - perc: the percentage from which we want to retrieve the value
    ///   - start: the lower bound
    ///   - end: the upper bound
    /// - Returns: the resulting float value, or nil if provided percentage is out of the bounds (0.0 to 1.0)
    func value(forPercentage perc:CGFloat, start:CGFloat, end:CGFloat) -> CGFloat? {
        guard perc >= 0.0 || perc <= 1.0 else { return nil }
        
        // calculate the value from the given percentage
        let min = CGFloat.minimum(start, end)
        let max = CGFloat.maximum(start, end)
        let relativePerc = start > end ? 1 - perc : perc
        let val = min + (max - min) * relativePerc
        return val
    }
    
}

class SwipeableItemTransformation: SwipeableItem {
    
    /// The weak reference to the actual view
    weak private(set) var view:UIView? = nil
    
    /// The transform value to be associated to the SwipeableView state `collapsed`
    private var start:CGFloat = 0.0
    
    /// The transform value to be associated to the SwipeableView state `expanded`
    private var end:CGFloat = 0.0
    
    /// indicates which type of transtormation this component is performing
    ///
    /// - if 0 then is a rotation transformation
    /// - if 1 then is a scaling transformation
    private var transformType = 0
    
    /// Returns the transformation angle from the current view
    private var currentAngle: CGFloat {
        guard let transform = self.view?.transform else { return 0.0 }
        return atan2(CGFloat(transform.b), CGFloat(transform.a))
    }
    
    /// Returns the transformation scale factor for the current view
    private var currentScale: CGFloat {
        guard let transform = self.view?.transform else { return 1.0 }
        return sqrt(pow(transform.a, 2) + pow(transform.c, 2))
    }
    
    var isValid: Bool { self.view != nil }
    
    func set(expanded: Bool) {
        guard let v = self.view else { return }
        switch self.transformType {
        case 0:
            v.transform = self.transform(withAngle: (expanded ? self.end : self.start))
        case 1:
            v.transform = self.transform(withScale: (expanded ? self.end : self.start))
        default:
            break
        }
    }
    
    func set(percentage: CGFloat) {
        guard let v = self.view else { return }
        guard let val = self.value(forPercentage: percentage, start: self.start, end: self.end) else { return }
        switch self.transformType {
        case 0:
            v.transform = self.transform(withAngle: val)
        case 1:
            v.transform = self.transform(withScale: val)
        default:
            break
        }
    }
    
    //MARK: Private
    
    /// Return the rotared affine transform for the existing view transform
    /// - Parameter angle: the angle to be applied
    /// - Returns: the resulting affine transfrom
    func transform(withAngle angle:CGFloat) -> CGAffineTransform {
        guard let vTransform = self.view?.transform else { return .identity }
        return vTransform.rotated(by: angle - self.currentAngle)
    }
    
    /// Returns the scaled affine transform for the existing view transform
    /// - Parameter scale: the scale factor to be applied
    /// - Returns: the resulting affine transfrom
    func transform(withScale scale:CGFloat) -> CGAffineTransform {
        guard let vTransform = self.view?.transform else { return .identity }
        let t = CGAffineTransform(translationX: vTransform.tx, y: vTransform.ty)
        let t0 = t.concatenating(CGAffineTransform(rotationAngle: self.currentAngle))
        return t0.concatenating(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    //MARK: Initializers
    
    /// Initialises the object with the provided view of which rotation angle need to be animated
    /// - Parameter view: the view to refer in order to animate his alpha channel
    /// - Parameter startAngle: the start/initial angle to be associated to the SwipeableView state `collapsed`
    /// - Parameter endAngle: the end/destination angle to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, 0 will be used instead
    /// - If `end` is not provided, π will be used instead
    ///
    init(rotating view:UIView, startAngle:CGFloat? = nil, endAngle:CGFloat? = nil){
        self.view = view
        self.start = startAngle ?? self.currentAngle
        self.end = endAngle ?? .pi
        self.transformType = 0
    }
    
    /// Initialises the object with the provided view of which scaling factor need to be animated
    /// - Parameter view: the view to refer in order to animate his alpha channel
    /// - Parameter startScale: the start/initial scale factor to be associated to the SwipeableView state `collapsed`
    /// - Parameter endScale: the end/destination scale factor to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, 0 will be used instead
    /// - If `end` is not provided, π will be used instead
    ///
    init(scaling view:UIView, startScale:CGFloat? = nil, endScale:CGFloat? = nil){
        self.view = view
        self.start = startScale ?? self.currentScale
        self.end = endScale ?? 0.5
        self.transformType = 1
    }
    
}

/// Representation of an animatable view cenrer in the context of the swipeable child view
class SwipeableItemCenter: SwipeableItem {
    
    /// The weak reference to the actual view
    weak private(set) var view:UIView? = nil
    
    /// The center point to be associated to the SwipeableView state `collapsed`
    private var start:CGPoint = .zero
    
    /// The center point to be associated to the SwipeableView state `expanded`
    private var end:CGPoint = .zero
    
    var isValid: Bool { self.view != nil }
    
    func set(expanded: Bool) {
        guard let v = self.view else { return }
        v.center = expanded ? self.end : self.start
    }
    
    func set(percentage: CGFloat) {
        guard let v = self.view else { return }
        guard percentage >= 0.0 || percentage <= 1.0 else { return }
        
        // calculate the value from the given percentage
        let x = self.start.x + (self.end.x - self.start.x) * percentage
        let y = self.start.y + (self.end.y - self.start.y) * percentage
        v.center = CGPoint(x: x, y: y)
    }
    
    //MARK: Initializers
    
    /// Initialises the object with the provided view of which center need to be animated
    /// - Parameter view: the view to refer in order to animate his center
    /// - Parameter start: the start/initial center to be associated to the SwipeableView state `collapsed`
    /// - Parameter end: the end/destination center to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, the current view center will be used instead
    /// - If `end` is not provided, CGPoint.zero will be used instead
    ///
    init(with view:UIView, start:CGPoint? = nil, end:CGPoint? = nil){
        self.view = view
        self.start = start ?? view.center
        self.end = end ?? .zero
    }
    
}

/// Representation of an animatable view color in the context of the swipeable child view
class SwipeableItemColor: SwipeableItem {

    /// The weak reference to the actual view
    weak private(set) var view:UIView? = nil

    /// The color to be associated to the SwipeableView state `collapsed`
    private var start:UIColor = .clear

    /// The color level to be associated to the SwipeableView state `expanded`
    private var end:UIColor = .clear
    
    /// Returns the color channels (rgba) for the `start` color
    private var startComponents:(CGFloat,CGFloat,CGFloat,CGFloat)? {
        var red:CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        guard self.start.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (red,green,blue,alpha)
    }
    
    /// Returns the color channels (rgba) for the `end` color
    private var endComponents:(CGFloat,CGFloat,CGFloat,CGFloat)? {
        var red:CGFloat = 0, green:CGFloat = 0, blue:CGFloat = 0, alpha:CGFloat = 0
        guard self.end.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        return (red,green,blue,alpha)
    }

    /// indicates which viwe property should be updated
    ///
    /// - if 0 then it will affect the backgroundColor
    /// - if 1 then it will affect the tintColor
    private var targetAttribute: Int = 0
    
    var isValid: Bool { self.view != nil }

    func set(expanded: Bool) {
        guard let startColor = self.startComponents, let endColor = self.endComponents else { return }
        self.setColor(expanded ? endColor : startColor)
    }

    func set(percentage: CGFloat) {
        guard let _ = self.view else { return }
        guard let startColor = self.startComponents, let endColor = self.endComponents else { return }
        guard let red = self.value(forPercentage: percentage, start: startColor.0, end: endColor.0) else { return }
        guard let green = self.value(forPercentage: percentage, start: startColor.1, end: endColor.1) else { return }
        guard let blue = self.value(forPercentage: percentage, start: startColor.2, end: endColor.2) else { return }
        guard let alpha = self.value(forPercentage: percentage, start: startColor.3, end: endColor.3) else { return }
        self.setColor( (red,green,blue,alpha) )
    }
    
    //MARK: Private
    
    /// Set the color for the current targeted attribute
    /// - Parameter cmp: the rgba color components to be set
    private func setColor(_ cmp:(CGFloat,CGFloat,CGFloat,CGFloat)) {
        guard let v = self.view else { return }
        let color = UIColor(red: cmp.0, green: cmp.1, blue: cmp.2, alpha: cmp.3)
        switch self.targetAttribute {
        case 0:
            v.backgroundColor = color
        case 1:
            v.tintColor = color
        default:
            break
        }
    }

    //MARK: Initializers

    /// Initialises the object with the provided view of which background color need to be animated
    /// - Parameter view: the view to refer in order to animate his alpha channel
    /// - Parameter start: the start/initial background color to be associated to the SwipeableView state `collapsed`
    /// - Parameter end: the end/destination background color to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, the current view background color will be used instead
    /// - If `end` is not provided, UIColor.clear will be used instead
    ///
    init(backgroundColorForView view:UIView, start:UIColor? = nil, end:UIColor? = nil){
        self.view = view
        self.start = start ?? (view.backgroundColor ?? .black)
        self.end = end ?? .clear
        self.targetAttribute = 0
    }

    /// Initialises the object with the provided view of which tint color need to be animated
    /// - Parameter view: the view to refer in order to animate his alpha channel
    /// - Parameter start: the start/initial tint color to be associated to the SwipeableView state `collapsed`
    /// - Parameter end: the end/destination tint color to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, the current view tint color will be used instead
    /// - If `end` is not provided, UIColor.clear will be used instead
    ///
    init(tintColorForView view:UIView, start:UIColor? = nil, end:UIColor? = nil){
        self.view = view
        self.start = start ?? view.tintColor
        self.end = end ?? .clear
        self.targetAttribute = 1
    }

}

/// Representation of an animatable view alph channel in the context of the swipeable child view
class SwipeableItemAlpha: SwipeableItem {
    
    /// The weak reference to the actual view
    weak private(set) var view:UIView? = nil
    
    /// The alpha level to be associated to the SwipeableView state `collapsed`
    private var start:CGFloat = 0.0
    
    /// The alpha level to be associated to the SwipeableView state `expanded`
    private var end:CGFloat = 0.0
    
    var isValid: Bool { self.view != nil }
    
    func set(expanded: Bool) {
        guard let v = self.view else { return }
        v.alpha = expanded ? self.end : self.start
    }
    
    func set(percentage: CGFloat) {
        guard let v = self.view else { return }
        guard let val = self.value(forPercentage: percentage, start: self.start, end: self.end) else { return }
        v.alpha = val
    }
    
    //MARK: Initializers
    
    /// Initialises the object with the provided view of which alpha channel need to be animated
    /// - Parameter view: the view to refer in order to animate his alpha channel
    /// - Parameter start: the start/initial alpha to be associated to the SwipeableView state `collapsed`
    /// - Parameter end: the end/destination alpha to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, the current view alpha channel will be used instead
    /// - If `end` is not provided, 0 will be used instead
    ///
    init(with view:UIView, start:CGFloat? = nil, end:CGFloat? = nil){
        self.view = view
        self.start = start ?? view.alpha
        self.end = end ?? 0.0
    }
    
}
    
/// Representation of an animatable layout constraint in the context of the swipeable child view
class SwipeableItemLayout: SwipeableItem {
    
    //MARK: Properties
    
    /// The weak reference to the actual layout constraint
    weak private(set) var layout:NSLayoutConstraint? = nil
    
    /// The expected layout axis to follow
    private(set) var isVerticalAxis:Bool = true
    
    /// The layout constraint constant to be associated to the SwipeableView state `collapsed`
    private var start:CGFloat = 0.0
    
    /// The layout constraint constant to be associated to the SwipeableView state `expanded`
    private var end:CGFloat = 0.0
    
    //MARK: Public
    
    var isValid: Bool { self.layout != nil }
    
    /// Returns the current percentage (from 0.0 to 1.0) of the layout constant between `start` and `end` values
    ///
    /// - percentage 0.0 is `start`
    /// - percentage 1.0 is `end`
    /// - percentage -1.0 if is an invalid percentage (eg. the layout is not available)
    var percentage:CGFloat {
        guard let lt = self.layout else { return -1.0 }
        let min = CGFloat.minimum(self.start, self.end)
        let max = CGFloat.maximum(self.start, self.end)
        let perc = (lt.constant - min) / (max - min)
        return self.start > self.end ? 1 - perc : perc
    }
    
    func set(expanded: Bool) {
        guard let lt = self.layout else { return }
        lt.constant = expanded ? self.end : self.start
        // layout the superview of the first available view item (first or second) for this layout constraint
        let refView:UIView? = lt.firstItem as? UIView ?? lt.secondItem as? UIView
        if let refView = refView, let superRefView = refView.superview {
            superRefView.layoutIfNeeded()
        }
    }
    
    func set(percentage:CGFloat){
        guard let lt = self.layout else { return }
        guard let val = self.value(forPercentage: percentage, start: self.start, end: self.end) else { return }
        lt.constant = val
    }
    
    /// Applies the new provided value to the current layout constant, taking into account the lower/upper bounds
    /// (which are `start` and `end`)
    /// - Parameter value: the new value to assign to the layout constant
    /// - Returns: false if the value exceeded the boundaries or the referred layout is not available
    @discardableResult func set(value:CGFloat) -> Bool {
        guard let lt = self.layout else { return false }
        switch self.valueInRangeResult(with: value) {
        case let check where check < 0:
            // limit the constant to the lower bound
            lt.constant = self.start
            return false
        case let check where check > 0:
            // limit the constant to the upper bound
            lt.constant = self.end
            return false
        default:
            // apply the new layout constant value
            lt.constant = value
            return true
        }
    }
    
    //MARK: Private
    
    /// Checks if the provided value is contained between `start`/`end` values
    /// - Parameter value: the value to be checked
    /// - Returns: 0 if the value is in the range, -1 if below the `start`, 1 if is over `end`
    private func valueInRangeResult(with value:CGFloat) -> Int {
        if self.start > self.end {
            return value > self.start ? -1 : (value < self.end ? 1 : 0)
        }else{
            return value < self.start ? -1 : (value > self.end ? 1 : 0)
        }
    }
    
    //MARK: Initializers
    
    /// Initialises the object with the provided layout constraint
    /// - Parameter layout: the layout constraint to refer
    /// - Parameter verticalAxis: if true, the layout direction will be considered vertical, otherwise horizontal
    /// - Parameter start: the start/initial constant to be associated to the SwipeableView state `collapsed`
    /// - Parameter end: the end/destination constant to be associated to the SwipeableView state `expanded`
    ///
    /// - If `start` is not provided, the current layout constant will be used instead
    /// - If `end` is not provided, 0 will be used instead
    ///
    /// - If `verticalAxis` is true, the swipe direction will rely on the vertical axis
    /// - If `verticalAxis` is false, the swipe direction will rely on the horizontal axis
    ///
    init(with layout:NSLayoutConstraint, verticalAxis:Bool = true, start:CGFloat? = nil, end:CGFloat? = nil){
        self.layout = layout
        self.isVerticalAxis = verticalAxis
        self.start = start ?? layout.constant
        self.end = end ?? 0.0
    }
    
    /// Default initializer
    init(){ }
}
