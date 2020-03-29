//
//  SampleChildViewController.swift
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

class SampleChildViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource:[String] = {
        var src = [String]()
        for i in 0..<40 { src.append("Item \(i)") }
        return src
    }()
    
    /// reference to the swipeview
    weak var swipeView:SwipeableView?
    
    @IBOutlet weak var sampleExtraLayout2: NSLayoutConstraint!
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeView?.addAnimatableItem(SwipeableItemLayout(with: sampleExtraLayout2,end: 180))
        self.tableView.reloadData()
    }
    
    //MARK: IBActions
    
    @IBAction func onTapCollapse(_ sender: Any) {
        self.swipeView?.isExpanded = false
    }
    
}

//MARK: - Tableview datasource/delegate methods
extension SampleChildViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = self.dataSource[indexPath.row]
        cell.textLabel?.textAlignment = .center
        return cell
    }

}
