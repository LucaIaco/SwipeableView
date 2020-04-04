//
//  ShowcaseChildViewController_8.swift
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

protocol Showcase8Protocol:class {
    
    /// Called when one of the supported character categories did change
    /// - Parameters:
    ///   - race: the acutal race character
    ///   - weapon: the actual weapon character
    ///   - coa: the actual coat of arms character
    func charactersDidChange(race:Character, weapon:Character, coa:Character)
}

class ShowcaseChildViewController_8: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// The collection view data source
    private lazy var datasource: [[Character]] = {
        let err = UnicodeScalar(0x1f6a8)!
        // fill 'Races'
        var races = stride(from: Int(0x1f40c), to: Int(0x1f43d), by: 1).map({Character(UnicodeScalar($0) ?? err)})
        [0x1f9b8,0x1f9b9,0x1f9d9,0x1f9da,0x1f9db,0x1f9dc,0x1f9dd,0x1f9de,0x1f9df,0x1f467, 0x1f468].forEach({races.insert(Character(UnicodeScalar($0) ?? err), at: 0)})
        // fill 'Weapons'
        var weapons = stride(from: Int(0x1f525), to: Int(0x1f52c), by: 1).map({Character(UnicodeScalar($0) ?? err)})
        [0x1f94a,0x1f3d1,0x1f4a7,0x2744,0x1fa93,0x26cf,0x2692,0x1f6e0,0x1f5e1,0x2694,0x1f3f9].forEach({weapons.append(Character(UnicodeScalar($0) ?? err))})
        // fill 'Coat of arms'
        var coa = stride(from: Int(0x1f52e), to: Int(0x1f532), by: 1).map({Character(UnicodeScalar($0) ?? err)})
        [0x2604,0x1f30a,0x2728,0x1f38f,0x1f9f8].forEach({coa.append(Character(UnicodeScalar($0) ?? err))})
        return [races,weapons,coa]
    }()
    
    // The current selected category index
    private var categoryIndex = 0 {
        didSet {
            self.loadData()
        }
    }
    
    // The index of the selected character per category
    private var categorySelectedCharacter:[Int] = [0,0,0]
    
    /// Any delegate for this view
    weak var delegate: Showcase8Protocol?
    
    /// Convenience getter which returns the list of currently selected characters per category (race, weapon, coa)
    var currentCaracters:[Character] {
        let race = self.datasource[0][self.categorySelectedCharacter[0]]
        let weapon = self.datasource[1][self.categorySelectedCharacter[1]]
        let coa = self.datasource[2][self.categorySelectedCharacter[2]]
        return [race,weapon,coa]
    }
    
    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    //MARK: IBActions
    
    @IBAction func onCategoryChanged(_ sender: UISegmentedControl) {
        self.categoryIndex = sender.selectedSegmentIndex
    }
    
    //MARK: Private
    
    private func setup(){
        self.view.backgroundColor = UIColor.Showcase8.colorB2
        self.loadData()
    }
    
    private func loadData(){
        self.collectionView.reloadData()
        self.collectionView.selectItem(at: IndexPath(row: self.categorySelectedCharacter[self.categoryIndex], section: 0), animated: false, scrollPosition: .bottom)
    }
  
}

//MARK: - Collection view data source and delegate
extension ShowcaseChildViewController_8 : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datasource[self.categoryIndex].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCellID", for: indexPath) as? CharacterCell else {
            return UICollectionViewCell()
        }
        cell.load(self.datasource[self.categoryIndex][indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prevCharacters = self.currentCaracters
        self.categorySelectedCharacter[self.categoryIndex] = indexPath.row
        let curCharacters = self.currentCaracters
        
        if let delegate = self.delegate, curCharacters != prevCharacters {
            delegate.charactersDidChange(race: curCharacters[0], weapon: curCharacters[1], coa: curCharacters[2])
        }
    }
}


//MARK: - Cell definition

class CharacterCell: UICollectionViewCell {
    
    @IBOutlet weak var charLabel: UILabel!
    
    //MARK: View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.Showcase8.colorB4.cgColor
        self.contentView.backgroundColor = UIColor.Showcase8.colorB1
        self.charLabel.text = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.charLabel.text = nil
    }
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.Showcase8.colorG1 : UIColor.Showcase8.colorB1
        }
    }
    
    //MARK: Public
    
    func load(_ item:Character){
        self.charLabel.text = String(item)
    }
}
