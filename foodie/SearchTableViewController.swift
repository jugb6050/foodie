//
//  SearchTableViewController.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-27.
//

import UIKit

class TableViewCell:UITableViewCell{
    

    @IBOutlet weak var cellImageView: CustomImageView!
    @IBOutlet weak var cellRestaurantName: UILabel!
    @IBOutlet weak var cellRestaurantCategories: UILabel!
    @IBOutlet weak var cellRestaurantAddress: UILabel!
    
}//UITableViewCell

class SearchTableViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {

    @IBOutlet weak var tableViewSearchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    let simpleCellIdentifier = "ReuseIdentifier"
    var restaurants = [Restaurant]()
    var filteredRestaurants = [Restaurant]()
    var selectedRow: Int?
    var isLoading = true
    
    // MARK: SearchTableViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewSearchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set copy of restaurants for searchbar filtering
        filteredRestaurants = restaurants
        
        // Opens searchbar right away
        self.tableViewSearchBar.becomeFirstResponder()
        
        // Programmatically sets action for NavBarItem (Back Button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
    }

    // MARK: Gesture Helper Functions

    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Lets prepare function know which row was selected
        selectedRow = sender.view!.tag
        performSegue(withIdentifier: "restaurantVC", sender: self)

    }
    
    @objc func backTapped(sender: UIBarButtonItem) {
        // Remove animation when return to previous view
        navigationController?.popViewController(animated: false)
    }
    
    
    // MARK: Segue Helper Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Pass restaurant data to another view controller
        if segue.destination is FoodTableViewController {
            let vc = segue.destination as? FoodTableViewController
            vc?.restaurant = self.restaurants[selectedRow!]
        }
    }
    
    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredRestaurants.count // tells the table view that the data comes from restaurants
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath) as? TableViewCell
        if (cell == nil) {
            cell = TableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: simpleCellIdentifier)
        }
        
        // Tap Gesture recognizes selected rows
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))

        // Tag field saves selected row to allow respective data to be passed to other VC later
        cell!.addGestureRecognizer(tap)
        cell!.tag = indexPath.row
        cell!.isUserInteractionEnabled = true

        let restaurant = self.filteredRestaurants[indexPath.row]
        
        // Add values to UI Components
        cell?.cellRestaurantName?.text = restaurant.name
        cell?.cellRestaurantCategories?.text = getCategoriesFromRestaurant(restaurant: restaurant)
        cell?.cellRestaurantAddress?.text = restaurant.location.address + ", " + restaurant.location.city
        
        
        // Verify that URL in object is valid URL
        if let url = URL(string: restaurant.logo.url!) {
            cell?.cellImageView.loadImage(from: url)
            cell?.cellImageView.layer.cornerRadius = 10
            cell?.cellImageView.clipsToBounds = true
        }
        
        return cell!
    }
    
    //  MARK: Search Bar
    
    // Returns restaurants which match the name or category (text change)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            filteredRestaurants = restaurants
        } else {
            filteredRestaurants = restaurants.filter({ restaurant -> Bool in
                let categories = getCategoriesFromRestaurant(restaurant: restaurant)
                return restaurant.name.contains(searchText) || categories.contains(searchText)
            
            })
        }
        tableView.reloadData()
    } 
    
    // MARK: General Helper Functions
    // Parses through object and returns all categories in string comma-separated form
    func getCategoriesFromRestaurant(restaurant: Restaurant) -> String {
        var categories = [String]()
        
        for category in restaurant.menus[0].food_categories{
            categories.append(category.name)
        }
        
        return categories.joined(separator: ", ")
    }
}

