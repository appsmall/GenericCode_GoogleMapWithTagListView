//
//  HomeVC.swift
//  IntegrateGoogleMapWithTagList
//
//  Created by Rahul Chopra on 21/08/18.
//  Copyright © 2018 AppSmall. All rights reserved.
//

import UIKit
import SearchTextField
import CoreLocation

class HomeVC: UIViewController {
    
    struct Storyboard {
        static let homeVCToMapVC = "homeVCToMapVC"
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var searchTextFieldLeadingConstraint: NSLayoutConstraint!
    var mapVC: MapVC?
    var selectedCategoriesArray = [String]()
    var tagViews = [TagView]()
    
    //Dummy Data
    var categoriesListArray = ["Bankruptcy", "Criminal", "Employement"]
    var attorniesDataArray: [String : Any] =
        ["Bankruptcy":
            ["data":
                ["0": ["name": "Rahul Chopra", "email": "rahul@gmail.com", "coordinates": CLLocationCoordinate2D(latitude: 30.7333, longitude: 76.7794)],
                 "1": ["name": "Aman Sharma", "email": "aman@gmail.com", "coordinates": CLLocationCoordinate2D(latitude: 30.7650, longitude: 76.7750)],
                 "2": ["name": "Karan", "email": "karan@gmail.com", "coordinates":  CLLocationCoordinate2D(latitude: 30.7164, longitude: 76.7444)]]],
                                              
         "Criminal":
            ["data":
                ["0": ["name": "Anil", "email": "anil@gmail.com", "coordinates": CLLocationCoordinate2D(latitude: 30.6775, longitude: 76.7120)],
                 "1": ["name": "Deepak", "email": "deepak@gmail.com", "coordinates": CLLocationCoordinate2D(latitude: 30.6993, longitude: 76.7322)]]]]
                            
    
    
    
    //MARK:- VIEW CONTROLLER METHODS
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK:- CREATE TAG VIEW
    func searchingCategoryListAndSelectIt() {
        searchTextField.filterStrings(categoriesListArray)
        searchTextField.startVisibleWithoutInteraction = true
        searchTextField.comparisonOptions = .caseInsensitive
        searchTextField.theme = .darkTheme()
        searchTextField.theme.font = UIFont.systemFont(ofSize: 15)
        searchTextField.theme.bgColor = UIColor(red: 88/255, green: 83/255, blue: 83/255, alpha: 1)
        
        //Perform action on selection of the Attorney Type Cell
        searchTextField.itemSelectionHandler = { [unowned self] filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            
            self.selectedCategoriesArray.append(item.title)
            self.createTagView(categoryName: item.title)
            self.getAttorneyUserDataAndShowOnMap(selectedCategory: item.title)
        }
    }
    
    func getAttorneyUserDataAndShowOnMap(selectedCategory: String) {
        if let mapVC = mapVC {
            mapVC.showMarkersAndInfoOfSelectedAttorneyInCategory(selectedCategory: selectedCategory)
        }
    }
    
    func createTagView(categoryName: String) {
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        if let constraint = searchTextFieldLeadingConstraint {
            constraint.isActive = false
        }
        
        let tagView = TagView(frame: CGRect.zero)
        tagView.label.sizeToFit()
        tagView.delegate = self
        tagView.label.text = categoryName
        tagViews.append(tagView)
        tagView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(tagView)
        self.view.layoutIfNeeded()
        
        let labelWidth = tagView.label.frame.size.width
        /***   will include labelWidth and crossButton   ***/
        let increasedWidth = labelWidth + 40
        /***  Adding 5 in ContentViewWidthConstraint and this 5 is comes from TagView Leading Constraint size.  ***/
        contentViewWidthConstraint.constant += increasedWidth + 5
        
        //Set Leading Constraint of TagView
        if selectedCategoriesArray.count == 1 {
            //If selectedCategoriesArray has only one value
            tagView.tagViewLeadingConstraint = tagView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
            tagView.tagViewLeadingConstraint?.isActive = true
        }
        else {
            //If selectedCategoriesArray has more than only one value
            if let lastTagView = tagViews.last {
                if let index = tagViews.index(of: lastTagView) {
                    let secondLastTagView = tagViews[index - 1]
                    tagView.tagViewLeadingConstraint = tagView.leadingAnchor.constraint(equalTo: secondLastTagView.trailingAnchor, constant: 5)
                    tagView.tagViewLeadingConstraint?.isActive = true
                }
            }
        }
        
        //Now set height, width, Y of TagView
        tagView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        tagView.heightAnchor.constraint(equalToConstant: self.searchTextField.frame.height - 8).isActive = true
        tagView.widthAnchor.constraint(equalToConstant: increasedWidth).isActive = true
        
        if let lastTagView = tagViews.last {
            searchTextFieldLeadingConstraint = self.searchTextField.leadingAnchor.constraint(equalTo: lastTagView.trailingAnchor, constant: 5)
            searchTextFieldLeadingConstraint.isActive = true
        }
        
    }
    
    //MARK:- IBACTIONS
    @IBAction func userLocationButtonPressed(_ sender: Any) {
        if let mapVC = mapVC {
            if let coordinate = mapVC.location {
                mapVC.focusCameraOnUserCurrentLocation(coordinate: coordinate)
                
                /******** Used to focus camera on user current location animately **********/
               /* mapVC.mapView.animate(with: GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)))
                mapVC.mapView.animate(toZoom: 12) */
                
            }
        }
    }
    
    //MARK:- NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Storyboard.homeVCToMapVC :
            if let destination = segue.destination as? MapVC {
                destination.homeDelegate = self
            }
            
        default:
            print("Default")
        }
    }

}

//MARK:- TEXTFIELD DELEGATE METHOD
extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTextField {
            searchingCategoryListAndSelectIt()
        }
    }
}

//MARK:- DELETE TAG VIEW
extension HomeVC: DeleteTagView {
    func deleteTagView(tagView: TagView) {
        guard let deletedCategory = tagView.label.text else {
            return
        }
        guard let deletedTagIndex = tagViews.index(of: tagView) else {
            return
        }
        
        if tagView == tagViews.first {
            print("First Element Deleted")
            if deletedTagIndex < tagViews.count - 1 {
                let nextTagView = tagViews[deletedTagIndex + 1]
                nextTagView.tagViewLeadingConstraint?.isActive = false
                nextTagView.tagViewLeadingConstraint = nextTagView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
                nextTagView.tagViewLeadingConstraint?.isActive = true
            }
            else {
                //If there is only one element in TagViews array
                searchTextFieldLeadingConstraint?.isActive = false
                searchTextFieldLeadingConstraint = self.searchTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
                searchTextFieldLeadingConstraint?.isActive = true
            }
        }
        else if tagView == tagViews.last {
            print("Last Element Deleted")
            let prevTagView = tagViews[deletedTagIndex - 1]
            searchTextFieldLeadingConstraint.isActive = false
            searchTextFieldLeadingConstraint = searchTextField.leadingAnchor.constraint(equalTo: prevTagView.trailingAnchor, constant: 5)
            searchTextFieldLeadingConstraint.isActive = true
        }
        else {
            print("Other than First and Last Element Deleted")
            let nextTagView = tagViews[deletedTagIndex + 1]
            let prevTagView = tagViews[deletedTagIndex - 1]
            nextTagView.tagViewLeadingConstraint?.isActive = false
            nextTagView.tagViewLeadingConstraint = nextTagView.leadingAnchor.constraint(equalTo: prevTagView.trailingAnchor, constant: 5)
            nextTagView.tagViewLeadingConstraint?.isActive = true
        }
        
        if let deletedCategoryIndex = selectedCategoriesArray.index(of: deletedCategory) {
            selectedCategoriesArray.remove(at: deletedCategoryIndex)
        }
        
        let labelWidth = tagView.label.frame.width
        /***  Adding 5 from ContentViewWidthConstraint and this 5 comes from TagView Leading Constraint size.   ***/
        let decreasedWidth = labelWidth + 40 + 5
        /***  Remove Previous Deleted TagView Width (Label + CrossButton + LeadingConstraint)  ***/
        contentViewWidthConstraint.constant -= decreasedWidth
        
        tagView.removeFromSuperview()
        tagViews.remove(at: deletedTagIndex)
        
    }
}
