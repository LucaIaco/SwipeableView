//
//  ShowcaseViewController_5.swift
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

class ShowcaseViewController_5: UIViewController {

    @IBOutlet weak var swipeableView: SwipeableView!
    @IBOutlet weak var flexLayout: NSLayoutConstraint!
    
    @IBOutlet var viewGroup: [UIView]!
    
    @IBOutlet weak var viewDot: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the swipeable view
        self.swipeableView.isPanGestureInverted = true
        self.swipeableView.flexibleLayout = .init(with: flexLayout, end: flexLayout.constant * 2)
        
        // Shuffle and customize the views
        viewDot.layer.cornerRadius = viewDot.frame.width / 2
        viewGroup.forEach { (v) in
            v.center = CGPoint(x: CGFloat.random(in: viewDot.frame.width...(view.frame.width - viewDot.frame.width)),
                               y: CGFloat.random(in: 150...600))
            v.layer.cornerRadius = v.frame.width / 2
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // place the views centers into the viewGroup in a way that will form a circle around the centered view viewDot
        let step = 2 * CGFloat.pi / CGFloat(viewGroup.count)
        let radius = viewDot.frame.width * 2
        for i in 0..<viewGroup.count {
            let endCenter = CGPoint(x: viewDot.center.x + radius * cos(step * CGFloat(i)),
                                    y: viewDot.center.y + radius * sin(step * CGFloat(i)))
            // add the animatable for the view.center
            self.swipeableView.addAnimatableItem(SwipeableItemCenter(with: viewGroup[i], end:endCenter))
        }
    }

}
