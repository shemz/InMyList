//
//  AllListsHandler.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 3/31/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import UIKit
import Firebase

private let ListNameCellIdentifier = "Cell"

class AllListCollectionViewController: UICollectionViewController {
    
    var forceSingleSelection: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ListNameCellIdentifier)
        collectionView.allowsMultipleSelection = true
        clearsSelectionOnViewWillAppear = true
        
        //Load lists with DB. Until it loads we show what we have in the shared user manager.
        UserListManager.sharedUserLists.observerDataFromDB { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    //Perform segue to display the items in the selected list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath  = sender as? IndexPath,
            let listDetailsVC = segue.destination as? ItemsInAListDisplayContainer {
            listDetailsVC.listName = UserListManager.sharedUserLists.listInfoModels[indexPath.row].listName
        }
    }
    
    
    //The following method will remove tick marks from collection view cells when cancel is pressed
    func handleCancelAction(){
        collectionView.indexPathsForSelectedItems?.forEach { self.collectionView.deselectItem(at: $0, animated: false) }
    }
    
    //The following method will remove selected lists from databse
    func handleDeleteAction(){
        //It is better to get the listname from the database instead of getting it from a cell.
       self.collectionView.indexPathsForSelectedItems?.map {
            UserListManager.sharedUserLists.listInfoModels[$0.row].listName
        }.forEach { (listName) in
            UserListManager.sharedUserLists.removeListFromDBWith(name: listName)
        }
    }
}

// MARK: UICollectionViewDataSource & Delegate
extension AllListCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserListManager.sharedUserLists.listInfoModels.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ListNameDisplayCell
        cell.listNameDisplayLabel.text = UserListManager.sharedUserLists.listInfoModels[indexPath.row].listName
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerReusableView = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            
            return headerReusableView!
        }
        else {
            let footerReusableView = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
            let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout
            flowLayout?.sectionFootersPinToVisibleBounds = true
            
            return footerReusableView!
        }
    }
    
    
    //Identify the list name that is selected by the user
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        if forceSingleSelection {
            self.collectionView.deselectItem(at: indexPath, animated: false)
            self.performSegue(withIdentifier: "displaySelectedListDetails", sender: indexPath)
        }
    }
    
}

// MARK: AllListActionsProtocol
extension AllListCollectionViewController: AllListActionsProtocol{
    func allowMultiSelection() {
        forceSingleSelection = false
    }
    
    func cancelSelection() {
        forceSingleSelection = true
        self.handleCancelAction()
    }
    
    func deleteSelectedLists() {
        forceSingleSelection = true
        self.handleDeleteAction()
    }
    
}
