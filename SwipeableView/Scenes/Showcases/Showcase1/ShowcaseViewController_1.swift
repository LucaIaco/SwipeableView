//
//  ShowcaseViewController_1.swift
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

class ShowcaseViewController_1: UIViewController {

    @IBOutlet weak var flexLayout: NSLayoutConstraint!
    @IBOutlet weak var swipeView: SwipeableView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var switchExpandedState: UISwitch!
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.swipeView.delegate = self
        self.swipeView.flexibleLayout = .init(with: self.flexLayout, end: 40.0)
    }

    //MARK: IBActions
    
    @IBAction func onIndicatorPositionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            swipeView.indicatorPosition = .top
        case 1:
            swipeView.indicatorPosition = .bottom
        case 2:
            swipeView.indicatorPosition = .left
        case 3:
            swipeView.indicatorPosition = .right
        default:
            break
        }
    }
    
    @IBAction func onIndicatorColorsChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            swipeView.indicatorColors = SwipeableView.defaultIndicatorColors
        case 1:
            swipeView.indicatorColors = (.green,.red)
        case 2:
            swipeView.indicatorColors = (.black,.white)
        case 3:
            swipeView.indicatorColors = (.yellow,.blue)
        default:
            break
        }
    }
    
    @IBAction func onExpandStateChanged(_ sender: UISwitch) {
        self.swipeView.isExpanded = sender.isOn
    }
    
    @IBAction func onIndicatorVisibilityChanged(_ sender: UISwitch) {
        self.swipeView.isSwipeIndicatorVisible = sender.isOn
    }
    
    @IBAction func onHideWhenExpandedChanged(_ sender: UISwitch) {
        self.swipeView.hideIndicatorWhenExpanded = sender.isOn
    }
    
    @IBAction func onShowRoundedCornersChanged(_ sender: UISwitch) {
        self.swipeView.hasRoundedCorners = sender.isOn
    }
    
    @IBAction func onPlugChildViewChanged(_ sender: UISwitch) {
        if sender.isOn {
            // attach the child view
            if let childViewController = self.storyboard?.instantiateViewController(withIdentifier:"child_Id1") as? SampleChildViewController {
                // alternative way to interact with the swipeable view from within a child view
                childViewController.swipeView = self.swipeView
                // plug the child view into the swipeable view
                self.swipeView.setChildView(childVC: childViewController, parentVC: self)
            }
        } else {
            self.swipeView.removeChildView()
        }
    }
    
    @IBAction func onChildViewInteractionChanged(_ sender: UISwitch) {
        self.swipeView.childViewInteractionOnExpandedOnly = sender.isOn
    }
    
}

extension ShowcaseViewController_1: SwipeableViewProtocol {
    
    func swipeableViewDidExpand(swipeableView: SwipeableView, previousState: Bool) {
        self.switchExpandedState.isOn = swipeableView.isExpanded
        self.lblPercentage.text = String(format: "%.1f %%", swipeableView.currentPercentage * 100)
    }
    
    func swipeableViewDidCollapse(swipeableView: SwipeableView, previousState: Bool) {
        self.switchExpandedState.isOn = swipeableView.isExpanded
        self.lblPercentage.text = String(format: "%.1f %%", swipeableView.currentPercentage * 100)
    }
    
    func swipeableViewDidPan(swipeableView: SwipeableView, percentage: CGFloat) {
        self.lblPercentage.text = String(format: "%.1f %%", percentage * 100)
    }
}
