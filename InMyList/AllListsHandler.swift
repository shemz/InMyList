//
//  AllListsHandler.swift
//  InMyList
//
//  Created by vignesh ramanathan on 3/31/19.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit
import Firebase

struct ListNames{
    var listName: String
    var dateCreated: String
    var status: String
}

private let reuseIdentifier = "Cell"

class AllListsHandler: UICollectionViewController {
    
    var userListSet = ["ListOne","ListTwo","ListThree"]
    
    var listNamesFromDB:[ListNames] = []
    
    let userListsRefDB = Database.database().reference(withPath: "userLists")
    
    var listNameSelected: String = ""
    
    var singleSelection: Bool = true
    
    var selectedMultipleIndexPaths:[IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Inside collection view")
//        listNamesFromDB.removeAll()
        getListNamesFromDB()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    
    func configureCollectionView(){
        let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.sectionFootersPinToVisibleBounds = true
        print("Sticky footer")
    }
    //Handle header and footer in collectionview as supplementaryelement
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("Inside supplementary view")
        if kind == UICollectionView.elementKindSectionHeader {
            print("Header view")
            let headerReusableView = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            
            return headerReusableView!
        }
        else {
                print("footer view")
                let footerReusableView = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
                let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout
                flowLayout?.sectionFootersPinToVisibleBounds = true
                print("Sticky footer")
            
                return footerReusableView!
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("listnamesFoundcount: ",listNamesFromDB.count)
        return listNamesFromDB.count
        
    }
    
    //Identify the list name that is selected by the user
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        if singleSelection {
            let cell = collectionView.cellForItem(at: indexPath) as! listNameDisplayCell
            //Hide the tick image in single selection mode
            cell.tickImage.isHidden = true
            print("Selected cell text ", cell.listNameDisplayLabel.text!)
            listNameSelected = (cell.listNameDisplayLabel.text)!
            
            //perform segue to display the details of the selected list
            self.performSegue(withIdentifier: "displaySelectedListDetails", sender: indexPath)
        }
        else {
            print("list item selected")
            selectedMultipleIndexPaths = self.collectionView!.indexPathsForSelectedItems!
       /*     for i in 1...selectedMultipleIndexPaths.count {
                print("i:",i)
                print("Selected items in list", self.collectionView.cellForItem(at: selectedMultipleIndexPaths[i-1]))
            }*/
        }
    }

    //Perform segue to display the items in the selected list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {return}
        let listDetailsVC = segue.destination as? ViewController
        listDetailsVC?.listName = listNameSelected
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! listNameDisplayCell
      
        cell.listNameDisplayLabel.text = listNamesFromDB[indexPath.row].listName
        cell.listNameDisplayLabel.layer.cornerRadius = 10
        cell.listNameDisplayLabel.clipsToBounds = true
        cell.backgroundColor = UIColor.clear
        cell.listNameDisplayLabel.layer.borderColor = UIColor.white.cgColor
        cell.listNameDisplayLabel.layer.borderWidth = 3
        
        // Configure the cell
    
        return cell
    }
    
    //The following method will remove tick marks from collection view cells when cancel is pressed
    func handleCancelAction(){
        if selectedMultipleIndexPaths.count > 0{
            for i in 1...selectedMultipleIndexPaths.count {
                print("i:",i)
                print("Selected items in list", self.collectionView.cellForItem(at: selectedMultipleIndexPaths[i-1]))
            
                let cell = self.collectionView.cellForItem(at: selectedMultipleIndexPaths[i-1]) as! listNameDisplayCell
                cell.tickImage.isHidden = true
            }
        }
    }
    
    //The following method will remove selected lists from databse
    func handleDeleteAction(){
        
        for i in 1...selectedMultipleIndexPaths.count {
            print("i:",i)
            print("Selected items in list", self.collectionView.cellForItem(at: selectedMultipleIndexPaths[i-1]))
            
            let cell = self.collectionView.cellForItem(at: selectedMultipleIndexPaths[i-1]) as! listNameDisplayCell
       //     cell.tickImage.isHidden = true
            removeListsFromDB(selectedListName: cell.listNameDisplayLabel.text!)
        }
    }
    func getListNamesFromDB(){
        print("Get listnames for user")
//        self.listNamesFromDB.removeAll()
        print("listNamesFromDB before read",listNamesFromDB)
        var list:ListNames = ListNames(listName: "", dateCreated: "", status: "")
        
        //Create a reference to the current user; replace shenba with username from login
        let listsOfCurrentUserRefDB = userListsRefDB.child(UserIDManager.sharedUserDetail.userID)
        
        //Create a reference to all lists of an user
        let allListsRefDB = listsOfCurrentUserRefDB.child("allListsOfUser")
        
        //Observe that reference for data changes
        
        allListsRefDB.observe(.value, with: {DataSnapshot in
            print("Observing data in userLists")
            self.listNamesFromDB.removeAll()
            for child in DataSnapshot.children{
                if let snapshot = child as? DataSnapshot{
                    let snapshotFromDB = snapshot.value as? [String : Any]
                    print("snapshotfromDB: ",snapshotFromDB)
                    list.dateCreated = snapshotFromDB?["dateCreated"] as! String
                    list.listName = snapshotFromDB?["listName"] as! String
                    list.status = snapshotFromDB?["status"] as! String
                    self.listNamesFromDB.append(list)
                }
                
//                print("listNamesFromDB: ",self.listNamesFromDB)
//                self.collectionView.reloadData()
            }
            print("listNamesFromDB after read: ",self.listNamesFromDB)
            
            //Upload shared Listnames present in UserListManager
            UserListManager.sharedUserLists.listNames = self.listNamesFromDB
            self.collectionView.reloadData()
        })
    }
    
    func removeListsFromDB(selectedListName: String){
        //Create a reference to the current user; replace shenba with username from login
        let listsOfCurrentUserRefDB = userListsRefDB.child(UserIDManager.sharedUserDetail.userID)
        
        //Create a reference to all lists of an user
        let allListsRefDB = listsOfCurrentUserRefDB.child("allListsOfUser")
        
        print("List to be deleted from userLists", selectedListName)
        //Create reference to the specific list from available lists of user
        let selectedListRefDB = allListsRefDB.child(selectedListName)
        
        //This removes the node from userLists which contains all the list names of a particular user
        selectedListRefDB.removeValue()
        
        //The following code will remove node from userListItems, which contains the items in each list
        let userListItemsRefDB = Database.database().reference(withPath: "userListItems")
        
        print("List to be deleted from userListItems", selectedListName)
        userListItemsRefDB.child(UserIDManager.sharedUserDetail.userID).child(selectedListName).removeValue()
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

//This implementation defines the selectButtonTapped method which will be executed when the select button in the AllListsHandlerWithFooter view controller is tapped
extension AllListsHandler: MultipleSelectionProtocol{
    func selectButtonTapped(buttonTapped: String) {
        switch buttonTapped {
        case "select":
            print("select button tapped")
            self.collectionView.allowsMultipleSelection = true
            self.singleSelection = false
        case "cancel":
            print("cancel button tapped")
            self.collectionView.allowsMultipleSelection = false
            self.singleSelection = true
            self.handleCancelAction()
        case "delete":
            print("delete button tapped")
            self.collectionView.allowsMultipleSelection = false
            self.singleSelection = true
            self.handleDeleteAction()
        default:
            print("default")
        }
    }
}
