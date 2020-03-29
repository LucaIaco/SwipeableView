//
//  ShowcaseViewController_6.swift
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

class ShowcaseViewController_6: UIViewController {
    
    @IBOutlet weak var swipeableView: SwipeableView!
    @IBOutlet weak var flexLayout: NSLayoutConstraint!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup the swipeable view
        self.swipeableView.isPanGestureInverted = true
        self.swipeableView.flexibleLayout = .init(with: flexLayout, end: flexLayout.constant * 2)
        
        // make fancy animation with colors (swap backgroundColor with tintColor then interpolate them for animation)
        let stackViewCols = self.stackView.arrangedSubviews.compactMap({$0 as? UIStackView})
        for k in 0..<stackViewCols.count{
            let stackViewRow = stackViewCols[k]
            for i in 0..<stackViewRow.arrangedSubviews.count {
                let view = stackViewRow.arrangedSubviews[i]
                if (k+i).isMultiple(of: 2) {
                    let col1 = view.backgroundColor
                    view.backgroundColor = view.tintColor
                    view.tintColor = col1
                }
                self.swipeableView.addAnimableItem(SwipeableAnimableColor(backgroundColorForView: view, end:view.tintColor) )
                self.swipeableView.addAnimableItem(SwipeableAnimableColor(tintColorForView: view, end: view.backgroundColor) )
            }
        }
        
    }
    
}
