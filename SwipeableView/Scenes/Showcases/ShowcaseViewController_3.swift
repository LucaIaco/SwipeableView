//
//  ShowcaseViewController_3.swift
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

class ShowcaseViewController_3: UIViewController {

    @IBOutlet weak var swipeableView: SwipeableView!
    @IBOutlet weak var flexLayout: NSLayoutConstraint!
    
    @IBOutlet weak var animatableLayoutPupilLeft: NSLayoutConstraint!
    @IBOutlet weak var animatableLayoutPupilRight: NSLayoutConstraint!
    
    @IBOutlet weak var animatableLayoutMouthPart0: NSLayoutConstraint!
    @IBOutlet weak var animatableLayoutMouthPart1: NSLayoutConstraint!
    @IBOutlet weak var animatableLayoutMouthPart2: NSLayoutConstraint!
    @IBOutlet weak var animatableLayoutMouthPart3: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the swipeable view
        self.swipeableView.isPanGestureInverted = true
        self.swipeableView.flexibleLayout = .init(with: flexLayout, end: flexLayout.constant * 2)
        
        // this will animate the "pupils"
        let pupilsEnd = (animatableLayoutPupilLeft.firstItem as? UIView)?.frame.height ?? 40
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: animatableLayoutPupilLeft, end: pupilsEnd))
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: animatableLayoutPupilRight, end: pupilsEnd))
        
        // this will animate the layouts for the "mouth" :)
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: animatableLayoutMouthPart0,
        end: -20))
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: animatableLayoutMouthPart1,
        end: -10))
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: animatableLayoutMouthPart2,
        end: -10))
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: animatableLayoutMouthPart3,
        end: -20))
        
    }
}
