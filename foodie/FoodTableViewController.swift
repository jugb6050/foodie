//
//  FoodTableViewController.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-29.
//

import UIKit
let simpleCellIdentifier = "ReuseIdentifier"

class FoodViewCell: UITableViewCell {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodDescription: UILabel!
    @IBOutlet weak var foodPrice: UILabel!
    @IBOutlet weak var foodImage: CustomImageView!
    var section: Int!
    var row: Int!
}

class FoodTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var restaurant: Restaurant!
    var foodCategories = [[Food]]()
    var categoryIDs: Dictionary<String, String> = [:]
    var selectedFoodItem: Food?
    @IBOutlet weak var subtotalLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewCart: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        parseMenuItems()
        saveCategoryIDs()
        updateViewCartSubtotal()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartView(_:)), name: Notification.Name("cartData"), object: nil)
        
        renderViewCart()
    }

    override func viewDidAppear(_ animated: Bool) {
        isCartVisible()
    }
    
    // Set Animation for transition between hidden and visible view
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    // Set view visible/invisible for cart based on items added
    func isCartVisible() {
        for constraint in self.view.constraints{
            if constraint.identifier == "tableViewBottomSpace" {
                if(Cart.getCount() > 0) {
                    // Show the cart
                    constraint.constant = 150
                    setView(view: self.viewCart, hidden: false)
                } else {
                    // Hide the cart
                    self.viewCart.isHidden = true
                }
            }
        }
    }
    
    @objc func updateCartView(_ notification: Notification) {
        // Sees if there have been any changes to the singleton class
        self.subtotalLabel.text = String(format: "%.2f", Cart.getCartSubTotal())
        // and applys the changes to the UI
        
    }
    
    func updateViewCartSubtotal(){
        self.subtotalLabel.text = String(format: "%.2f", Cart.getCartSubTotal())
    }
    
    // Adding food items from restaurant object to foodItems array
    func parseMenuItems() {
        let food_categories = restaurant.menus[0].food_categories
        
        for category_i in 0...food_categories.count-1 {
            var category_foods = [Food]()
            for food_i in 0...food_categories[category_i].foods.count-1{
                let food: Food = food_categories[category_i].foods[food_i]
                category_foods.append(food)
            }
            self.foodCategories.append(category_foods)
        }
    }
    
    // Create a dictonary to retrieve category name based on category ID
    func saveCategoryIDs() {
        let categories = restaurant.menus[0].food_categories

        for category in categories {
            self.categoryIDs[category._id] = category.name
        }
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        // Get the cell that was selected to obtain the Food Item
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            let cell = tableView(self.tableView, cellForRowAt: indexPath) as! FoodViewCell
            selectedFoodItem = self.foodCategories[cell.section][cell.row]
        }
        performSegue(withIdentifier: "addFoodItemVC", sender: self)
    }
    
    func renderViewCart() {
        // Create view and set dimensions
        // Set styling
        viewCart.isHidden = true
        viewCart.layer.cornerRadius = 10
        viewCart.backgroundColor = UIColor.black
        
        // Cart will be empty on first load, so don't show UI View
//        self.view.addSubview(viewCart)
        

    }
    
    // MARK: Segue Helper Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Pass restaurant data to another view controller
        if segue.destination is AddFoodItemController {
            let vc = segue.destination as? AddFoodItemController
            vc?.food = self.selectedFoodItem
            vc?.restaurantID = self.restaurant._id
        }
    }
    
    // MARK: - Table view data source

    // Sets the total number of rows for each respective section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = self.foodCategories[section]
        return category.count
    }
    
    // Dynamically sets the number of sections e.g. food categories
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.foodCategories.count
    }

    // Sets the view components for the Header Section cell
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Get category name
        let category = self.foodCategories[section]
        let categoryName = self.categoryIDs[category[0].category]
        
        // Set label with styles
        let label = PaddingLabel()
        label.text = categoryName
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        label.paddingLeft = 8

        return label
    }

    // Sets the height for the Header Section cell
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath) as? FoodViewCell
        if (cell == nil) {
            cell = FoodViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: simpleCellIdentifier)
        }
        
        // Tap Gesture recognizes selected rows
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))

        // Tag field saves selected row to allow respective data to be passed to other VC later
        cell!.addGestureRecognizer(tap)
        cell!.tag = indexPath.row
        cell!.isUserInteractionEnabled = true
    
        let food = self.foodCategories[indexPath.section][indexPath.row]

        cell?.foodName.text = food.name
        cell?.foodDescription.text = food.description
        cell?.foodPrice.text = "$" + String(food.price)
        cell?.row = indexPath.row
        cell?.section = indexPath.section
        
        // Verify that URL in object is valid URL
        if (food.images[0].url != nil) {
            if let url = URL(string: food.images[0].url!) {
                cell?.foodImage.loadImage(from: url)
                cell?.foodImage.layer.cornerRadius = 10
                cell?.foodImage.clipsToBounds = true
            }
        }
        return cell!
    }
}
