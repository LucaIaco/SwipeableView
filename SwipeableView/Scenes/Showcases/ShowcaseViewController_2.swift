//
//  ShowcaseViewController_2.swift
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

class ShowcaseViewController_2: UIViewController {

    @IBOutlet weak var swipeTop: SwipeableView!
    @IBOutlet weak var flexSwipeTop: NSLayoutConstraint!
    
    @IBOutlet weak var swipeBottom: SwipeableView!
    @IBOutlet weak var flexSwipeBottom: NSLayoutConstraint!
    
    @IBOutlet weak var swipeLeft: SwipeableView!
    @IBOutlet weak var flexSwipeLeft: NSLayoutConstraint!
    
    @IBOutlet weak var swipeRight: SwipeableView!
    @IBOutlet weak var flexSwipeRight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeTop.indicatorPosition = .bottom
        swipeTop.flexibleLayout = .init(with: flexSwipeTop, end: view.frame.height / 3)
        
        // due the actual nature of the layout referred by flexSwipeBottom, we need to invert the gesture
        swipeBottom.isPanGestureInverted = true
        swipeBottom.flexibleLayout = .init(with: flexSwipeBottom, end: view.frame.height / 3)
        
        swipeLeft.indicatorPosition = .right
        swipeLeft.flexibleLayout = .init(with: flexSwipeLeft, verticalAxis:false, end: view.frame.width / 2)
        
        swipeRight.indicatorPosition = .left
        // due the actual nature of the layout referred by flexSwipeBottom, we need to invert the gesture
        swipeRight.isPanGestureInverted = true
        swipeRight.flexibleLayout = .init(with: flexSwipeRight, verticalAxis:false, end: view.frame.width / 2)
    }
 
}
