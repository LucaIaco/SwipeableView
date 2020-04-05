//
//  ShowcaseViewController_8.swift
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

class ShowcaseViewController_8: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var lblSwipeUp: UILabel!
    @IBOutlet weak var swipeableView: SwipeableView!
    @IBOutlet weak var flexLayout: NSLayoutConstraint!
    
    @IBOutlet weak var lblRace: UILabel!
    @IBOutlet weak var lblWeapon: UILabel!
    @IBOutlet weak var lblCoa: UILabel!
    
    @IBOutlet weak var topLabelsConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftcenterContraint: NSLayoutConstraint!
    @IBOutlet weak var rightcenterConstraint: NSLayoutConstraint!
    
    private weak var characterPickerView:ShowcaseChildViewController_8?
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    //MARK: Private methods
    
    private func setup() {
        self.setupView()
        self.setupSwipeable()
        self.setupChildview()
        self.setupLabels()
    }
    
    private func setupView() {
        self.view.backgroundColor = UIColor.Showcase8.colorB0
        // plug color animatable item
        self.swipeableView.addAnimatableItem(SwipeableItemColor(backgroundColorForView: self.view,
                                                                end: UIColor.Showcase8.colorB1))
        // plug alpha animatable item
        self.swipeableView.addAnimatableItem(SwipeableItemAlpha(with: self.lblSwipeUp))
    }
    
    private func setupSwipeable() {
        self.swipeableView.isPanGestureInverted = true
        self.swipeableView.flexibleLayout = .init(with: flexLayout, end: view.frame.height / 2)
        self.swipeableView.childViewInteractionOnExpandedOnly = false
        self.swipeableView.indicatorColors = (UIColor.Showcase8.colorB4,UIColor.Showcase8.colorB1)
    }
    
    private func setupChildview() {
        if let characterPickerView = self.storyboard?.instantiateViewController(withIdentifier:"child_Id8") as? ShowcaseChildViewController_8 {
            self.characterPickerView = characterPickerView
            // plug the child view into the swipeable view
            self.swipeableView.setChildView(childVC: characterPickerView, parentVC: self)
            // plug the character picker delegate
            characterPickerView.delegate = self
        }
    }
    
    private func setupLabels() {
        if let currentCharacters = self.characterPickerView?.currentCaracters {
            self.lblRace.setTextAnimated(String(currentCharacters[0]))
            self.lblWeapon.setTextAnimated(String(currentCharacters[1]))
            self.lblCoa.setTextAnimated(String(currentCharacters[2]))
        }
        // plug layout animatable items
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: self.topLabelsConstraint, start: view.frame.height / 4, end: (view.frame.height / 4) - 100 ))
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: self.leftcenterContraint))
        self.swipeableView.addAnimatableItem(SwipeableItemLayout(with: self.rightcenterConstraint))
        // plug transform animable items (scaling)
        self.swipeableView.addAnimatableItem(SwipeableItemTransform(scaling: self.lblRace, endScale: 1.7))
        self.swipeableView.addAnimatableItem(SwipeableItemTransform(scaling: self.lblWeapon, endScale: 1.7))
        self.swipeableView.addAnimatableItem(SwipeableItemTransform(scaling: self.lblCoa, endScale: 1.7))
        // plug transform animable items (rotating)
        self.swipeableView.addAnimatableItem(SwipeableItemTransform(rotating: self.lblRace, endAngle: CGFloat.pi * 2))
        self.swipeableView.addAnimatableItem(SwipeableItemTransform(rotating: self.lblWeapon, endAngle: CGFloat.pi * 2))
        self.swipeableView.addAnimatableItem(SwipeableItemTransform(rotating: self.lblCoa, endAngle: CGFloat.pi * 2))
    }

}

//MARK: - Showcase8Protocol implementation
extension ShowcaseViewController_8 : Showcase8Protocol {
    func charactersDidChange(race: Character, weapon: Character, coa: Character) {
        self.lblRace.setTextAnimated(String(race))
        self.lblWeapon.setTextAnimated(String(weapon))
        self.lblCoa.setTextAnimated(String(coa))
    }
}

//MARK: - Showcase 8 color namespace
extension UIColor {
    struct Showcase8 {
        static let colorB0 = UIColor(red: 188/255, green: 233/255, blue: 255/255, alpha: 1)
        static let colorB1 = UIColor(red: 168/255, green: 213/255, blue: 255/255, alpha: 1)
        static let colorB2 = UIColor(red: 130/255, green: 180/255, blue: 230/255, alpha: 1)
        static let colorB3 = UIColor(red: 110/255, green: 187/255, blue: 1, alpha: 1)
        static let colorB4 = UIColor(red: 7/255, green: 60/255, blue: 110/255, alpha: 1)
        static let colorG1 = UIColor(red: 172/255, green: 237/255, blue: 152/255, alpha: 1)
    }
}

extension UILabel {
    
    /// Fancy method for changing the text color animated
    /// - Parameter text: the new text to be set to this label
    func setTextAnimated(_ text:String?){
        guard text != self.text else { return }
        UIView.transition(with: self, duration: 0.3, options: [.beginFromCurrentState,.transitionFlipFromRight], animations: {
            self.text = text
        }, completion: nil)
    }
}
