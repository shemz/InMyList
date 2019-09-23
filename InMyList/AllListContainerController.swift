//
//  AllListsHandlerWithFooter.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 4/15/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import UIKit
import Firebase

//This protocol is used when select button is tapped and the corresponding action needs to be performed in the collectionview
protocol AllListActionsProtocol:class{
    func allowMultiSelection()
    func cancelSelection()
    func deleteSelectedLists()
}

class AllListContainerController: UIViewController {
    
    var newListName: String = " "
    var duplicateListFound: Bool = false
    var alert:UIAlertController!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var addNewListButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var multipleSelectionDelegate:AllListActionsProtocol?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //This page is the page after signin; removing back from the navigation bar to prevent user from pressing back button and navigation to signin screen
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func addNewList(_ sender: Any) {
        createNewList()
    }
    
    //This action displays user details in user detail page, and has a link to signout
    @IBAction func getUserDetails(_ sender: Any) {
        self.performSegue(withIdentifier: "presentUserDetails", sender: self)
    }
    
    //This method will be called when 'select' button is tapped
    @IBAction func selectMultipleLists(_ sender: Any) {
        if selectButton.currentTitle == "Select"{
            selectButton.setTitle("Cancel", for: .normal)
            deleteButton.isHidden = false
            multipleSelectionDelegate?.allowMultiSelection()
        }
        else{
            selectButton.setTitle("Select", for: .normal)
            deleteButton.isHidden = true
            multipleSelectionDelegate?.cancelSelection()
        }
    }
    
    //Delete button is tapped; Call deleteButtonTapped in AllListsHandler view controller
    @IBAction func deleteSelectedLists(_ sender: Any) {
        //Construct alert look to confirm delete
        alert = UIAlertController(title: "Delete Lists", message: "Do you want to delete the selected lists?", preferredStyle: .alert)
        
        //define add newList action
        let alertTitle = "Yes"
        let confirmDeleteAction = UIAlertAction(title: alertTitle, style: .default
            , handler: { [weak self] (action) -> Void in
                
                self?.selectButton.setTitle("Select", for: .normal)
                self?.deleteButton.isHidden = true
                self?.multipleSelectionDelegate?.deleteSelectedLists()
                //Delete action confirmed
        })
        alert.addAction(confirmDeleteAction)
        
        //define cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert,animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayListDetails"{
            // Prepare for segue; this will send the listname to viewController, which will send it to Table view controller
            if let viewController = segue.destination as? ItemsInAListDisplayContainer {
                viewController.listName = self.newListName
                //Set displayAlert to true, to display Alert controller to add new item for the new list
                viewController.isNewList = true
            }
        }
        
        //This is the embed segue of the container view to the collection view containing all lists of the user
        if segue.identifier == "displayAllLists"{
            if let allListsViewController = segue.destination as? AllListCollectionViewController{
                self.multipleSelectionDelegate = allListsViewController
            }
        }
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
            , handler: { [weak self] (action) -> Void in
                guard let newListNameAlert = self?.alert.textFields?[0].text
                    else { return }
                self?.newListName = newListNameAlert
                self?.checkIfNameIsDuplicateOrProceed()
                // self.performSegue(withIdentifier: "displayListDetails", sender: self)
        })
        alert.addAction(addListAction)
        
        //define cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert,animated: true)
    }
    
    func checkIfNameIsDuplicateOrProceed(){
        
        if UserListManager.sharedUserLists.hasAListWith(name: newListName) {
            alert = UIAlertController(title: "Duplicate List name", message: "User already has the list!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //If listname is not already present, segue to list details screen for further processing
            self.performSegue(withIdentifier: "displayListDetails", sender: self)
        }
    }
}
