//
//  ShowcaseHomeViewController.swift
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
//  SOFTWARE.c

import UIKit

class ShowcaseHomeViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var showCasesTableView: UITableView!
    @IBOutlet weak var labelText1: UILabel!
    @IBOutlet weak var labelText2: UILabel!
    @IBOutlet weak var topLabelText1Layout: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelText2Layout: NSLayoutConstraint!
    @IBOutlet weak var swipeableFlexLayout: NSLayoutConstraint!
    @IBOutlet weak var swipeableView: SwipeableView!
    
    private let showCases:[ShowCase] = [
        ShowCase(title: "Basic configurations", segueId: "segueShowcase1"),
        ShowCase(title: "Indicator positions", segueId: "segueShowcase2"),
        ShowCase(title: "Item: Layout", segueId: "segueShowcase3"),
        ShowCase(title: "Animable Item: Alpha channel", segueId: "segueShowcase4"),
        ShowCase(title: "Animable Item: View.center", segueId: "segueShowcase5"),
        ShowCase(title: "Animable Item: UIColor", segueId: "segueShowcase6"),
        ShowCase(title: "Animable Item: Scale / Rotate", segueId: "segueShowcase7")
    ]

    //MARK: View lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // customize the swipe indicator position
        self.swipeableView.indicatorPosition = .bottom
        // set the flexible layout which will allow the swipeable view to expand and collapse
        self.swipeableView.flexibleLayout = .init(with: swipeableFlexLayout, verticalAxis: true, end: 100.0)
        
        // add extra animable item which need to be interpolated along with the expand/collapse
        self.swipeableView.addAnimableItem(SwipeableAnimableLayout(with: topLabelText1Layout, end: -200))
        self.swipeableView.addAnimableItem(SwipeableAnimableAlpha(with: labelText1))
        self.swipeableView.addAnimableItem(SwipeableAnimableTransformation(scaling: labelText1))
        self.swipeableView.addAnimableItem(SwipeableAnimableLayout(with: bottomLabelText2Layout, end: 40.0))
        self.swipeableView.addAnimableItem(SwipeableAnimableAlpha(with: labelText2, end: 1.0))
        self.showCasesTableView.alpha = 0
        self.swipeableView.addAnimableItem(SwipeableAnimableAlpha(with: showCasesTableView, end: 1.0))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let showCase = sender as? ShowCase {
            segue.destination.title = showCase.title
        }
    }
}

//MARK: - UITableViewDataSource & UITableViewDelegate methods
extension ShowcaseHomeViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") else { return UITableViewCell() }
        cell.textLabel?.text = "Case \(indexPath.row+1) - \(self.showCases[indexPath.row].title)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let segueId = self.showCases[indexPath.row].segueId
        self.performSegue(withIdentifier: segueId, sender: self.showCases[indexPath.row])
    }

}

fileprivate extension ShowcaseHomeViewController {
    struct ShowCase {
        let title:String
        let segueId:String
    }
}
