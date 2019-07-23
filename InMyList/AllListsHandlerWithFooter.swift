//
//  AllListsHandlerWithFooter.swift
//  InMyList
//
//  Created by vignesh ramanathan on 4/15/19.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit
import Firebase

//This protocol is used when select button is tapped and the corresponding action needs to be performed in the collectionview
protocol MultipleSelectionProtocol:class{
    func selectButtonTapped(buttonTapped:String)
}

class AllListsHandlerWithFooter: UIViewController {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var addNewListButton: UIButton!
    var alert:UIAlertController!
    var newListName: String = " "
    var duplicateListFound: Bool = false
    var duplicateListAlert: UIAlertController!
    
   // let newListStatus: String = "open"
    
//    weak var dataRefresherDelegate:DataRefresherProtocol?
    
    weak var multipleSelectionDelegate:MultipleSelectionProtocol?
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This page is the page after signin; removing back from the navigation bar to prevent user from pressing back button and navigation to signin screen
        navigationController?.navigationBar.isHidden = true
      //  getUserIDFromEmail()
        // Do any additional setup after loading the view.
        print("user Id in here", UserIDManager.sharedUserDetail.userID)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    func createNewList(){
        //Construct alert look
        alert = UIAlertController(title: "New List", message: "Enter ListName", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter ListName here"
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            textField.textColor = UIColor.blue
        })
        
        //define add newList action
        let alertTitle = "Add"
        let addListAction = UIAlertAction(title: alertTitle, style: .default
            , handler: { (action) -> Void in
                guard let newListNameAlert = self.alert.textFields?[0].text
                    else {return}
                self.newListName = newListNameAlert
                print("New List Name: ", self.newListName)
                self.checkDuplicateListNames()
               // self.performSegue(withIdentifier: "displayListDetails", sender: self)
        })
        alert.addAction(addListAction)
        
        //define cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert,animated: true)
    }
    
    func checkDuplicateListNames(){
        let maxUserLists = UserListManager.sharedUserLists.listNames.count
        for i in 0..<maxUserLists {
            let list = UserListManager.sharedUserLists.listNames[i]
            print("listName: ",list.listName)
            if self.newListName.lowercased() == list.listName.lowercased(){
                self.duplicateListFound = true
                break
            }
        }
        if self.duplicateListFound{
            print("Duplicate List found")
            duplicateListFound = false
            duplicateListAlert = UIAlertController(title: "Duplicate List name", message: "User already has the list!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
            duplicateListAlert.addAction(okAction)
            self.present(duplicateListAlert, animated: true, completion: nil)
            print("duplicate alert created")
        }
        else{
            //If listname is not already present, segue to list details screen for further processing
            self.performSegue(withIdentifier: "displayListDetails", sender: self)
        }
    }
    
    @IBAction func addNewList(_ sender: Any) {
        createNewList()
    }
    
    //This action displays user details in user detail page, and has a link to signout
    @IBAction func getUserDetails(_ sender: Any) {
        print("profile button pressed")
        self.performSegue(withIdentifier: "presentUserDetails", sender: self)
    }
    //This method will be called when 'select' button is tapped
    @IBAction func selectMultipleLists(_ sender: Any) {
        if selectButton.currentTitle == "Select"{
            selectButton.setTitle("Cancel", for: .normal)
            deleteButton.isHidden = false
            self.multipleSelectionDelegate?.selectButtonTapped(buttonTapped: "select")
        }
        else{
            selectButton.setTitle("Select", for: .normal)
            deleteButton.isHidden = true
            cancelActionInitiated()
        }
    }
    
    //Delete button is tapped; Call deleteButtonTapped in AllListsHandler view controller
    @IBAction func deleteSelectedLists(_ sender: Any) {
        //Construct alert look to confirm delete
        alert = UIAlertController(title: "Delete Lists", message: "Do you want to delte the selected lists?", preferredStyle: .alert)
        
        //define add newList action
        let alertTitle = "Yes"
        let confirmDeleteAction = UIAlertAction(title: alertTitle, style: .default
            , handler: { (action) -> Void in

                self.selectButton.setTitle("Select", for: .normal)
                self.deleteButton.isHidden = true
                 self.multipleSelectionDelegate?.selectButtonTapped(buttonTapped: "delete")
                
                //Delete action confirmed
                print("Delete action confirmed")
        })
        alert.addAction(confirmDeleteAction)
        
        //define cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            self.deleteButton.isHidden = true
            self.selectButton.setTitle("Select", for: .normal)
            self.cancelActionInitiated()
        })
        
        alert.addAction(cancelAction)
        self.present(alert,animated: true)
        
    }
    
    func cancelActionInitiated() {
        //Call AllListsHandler with the isSelectTapped as false to indicate that cancel action has been initiated
        self.multipleSelectionDelegate?.selectButtonTapped(buttonTapped: "cancel")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayListDetails"{
            // Prepare for segue; this will send the listname to viewController, which will send it to Table view controller
            if let viewController = segue.destination as? ViewController {
                viewController.listName = self.newListName
                //Set displayAlert to true, to display Alert controller to add new item for the new list
                viewController.displayAlert = true
                print("ViewController segue")
            }
        }
        
        //This is the embed segue of the container view to the collection view containing all lists of the user
        if segue.identifier == "displayAllLists"{
            if let allListsViewController = segue.destination as? AllListsHandler{
                self.multipleSelectionDelegate = allListsViewController
                print("delegate set")
            }
        }
    }
    /*
    func writeToUserListsDB(){
        
        //Insert new record in to the userLists table
        print("writing list details to DB")
        
        let userListRefDB = listDetailsRefDB.child("shenba")
        let newListRefDB = userListRefDB.child(self.newListName as String!)
        
        let newListDetail = ["dateCreated": self.today(format: "dd-mm-yyyy"),
                             "listName": self.newListName,
        "status": self.newListStatus] as [String : Any]
        
        newListRefDB.setValue(newListDetail)
        
    }
    */
    /*
    func writeToUserListItemsDB(){
        //Insert new record with list name to userListItems table
        print("writing list name to userListItems table")
        
        let userListItemsRefDB = listItemsRefDB.child("shenba")
        let newListRefDB = userListItemsRefDB.child(self.newListName as String!)
        
        let insertItemDB = ["name": "newItem",
                            "quantity": 1,
                            "unit": "lb"] as [String : Any]
        newListRefDB.setValue(insertItemDB)
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    /*
    //Format today's date to the format required for the DB
    func today(format: String = "dd-mm-yyyy") -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    */

}
