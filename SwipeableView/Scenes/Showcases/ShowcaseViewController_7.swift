//
//  ShowcaseViewController_7.swift
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

class ShowcaseViewController_7: UIViewController {

    
    @IBOutlet weak var squareCoreView: UIView!
    @IBOutlet var squareBorderViews: [UIView]!
    
    @IBOutlet weak var swipeableView: SwipeableView!
    @IBOutlet weak var flexLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the swipeable view
        self.swipeableView.isPanGestureInverted = true
        self.swipeableView.flexibleLayout = .init(with: flexLayout, end: flexLayout.constant * 2)
        
        self.squareBorderViews.forEach { (v) in
            let angle:CGFloat = ([9,7,3,1].contains(v.tag) ? .pi/4 : .pi) * (v.tag.isMultiple(of: 2) ? -1 : 1)
            self.swipeableView.addAnimableItem(SwipeableAnimableTransformation(rotating: v, endAngle: angle))
            let scale:CGFloat = ([9,7,3,1].contains(v.tag) ? 0.3 : 0.5)
            self.swipeableView.addAnimableItem(SwipeableAnimableTransformation(scaling: v, endScale: scale))
        }
        self.swipeableView.addAnimableItem(SwipeableAnimableTransformation(scaling: squareCoreView, endScale: 1.5))   
    }
    
}
