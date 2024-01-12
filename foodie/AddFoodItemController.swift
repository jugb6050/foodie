//
//  AddFoodItemController.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-29.
//

import UIKit
import M13Checkbox

class AddFoodItemController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var foodImage: CustomImageView!
    @IBOutlet weak var decreaseCount: UIButton!
    @IBOutlet weak var increaseCount: UIButton!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var itemCounter: UILabel!
    @IBOutlet weak var viewOverlay: UIView!
    @IBOutlet weak var foodDescription: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    
    var overlay: UIView!
    var checkbox: M13Checkbox?
    
    var food: Food!
    var restaurantID: String = ""
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        checkIfItemsAddPrior()

    }
    
    func setupView() {
        foodImage.loadImage(from: URL(string: food.images[0].url!)!)
        mainTitle.text = food.name
        foodDescription.text = food.description
        
        changeButtonShape()
    }
    
    func checkIfItemsAddPrior() {
        if(!Cart.isEmpty()) {
            for i in 0...Cart.getCount() - 1 {
                // Item has been selected before
                let item: CartItem = Cart.getItem(index: i)!
                if(item.getFoodID() == food._id) {
                    updateCounterLabel(value: item.getQuantity())
                    self.count = item.getQuantity()
                    updateSubtotalLabel()
                    return
                }
            }
            return
        }
        
    }
    
    func changeButtonShape() {
        decreaseCount.layer.cornerRadius = 0.5 * decreaseCount.bounds.size.width
        decreaseCount.clipsToBounds = true
        decreaseCount.clipsToBounds = true
        
        increaseCount.layer.cornerRadius = 0.5 * increaseCount.bounds.size.width
        increaseCount.clipsToBounds = true
        increaseCount.clipsToBounds = true
    }
    
    func updateCounterLabel(value: Int) {
        itemCounter.text = String(value)
        
    }
    
    func updateSubtotalLabel() {
        let cost = Double(food.price * Double(count))
        subTotal.text = "$" + String(format: "%.2f", cost)
    }
    
    @IBAction func onPressIncrementButton(_ sender: Any) {
        self.count = self.count + 1
        updateCounterLabel(value: self.count)
        updateSubtotalLabel()
    }
    
    @IBAction func onPressDecrementButton(_ sender: Any) {
        // Prevent negative number of items
        if (self.count > 0){
            self.count = self.count - 1
            updateCounterLabel(value: self.count)
            updateSubtotalLabel()
        }
    }
    
    // Add item to cart only if verified (respective restaurant) and count > 0
    @IBAction func onPressAddToCart(_ sender: Any) {
        let isVerified = verifyCartItems()

        if(self.count != 0 && isVerified ) {
            addItemToCard()
            let someDict:[String:[CartItem]] = ["data": Cart.sharedInstance]
            
            // Push Notification to All Observers
            NotificationCenter.default.post(name: Notification.Name("cartData"), object: nil, userInfo: someDict)
            print("data pushed")
        }
    }
    
    func addItemToCard() {
        let item = CartItem(item: self.food, image: foodImage.image!, quantity: self.count, restaurant_id: self.restaurantID )
        Cart.addItem(newItem: item)
        addItemAddedOverlay()
        
    }
    // Ensure that items being added to cart only belong to one restuarant
    func verifyCartItems() -> Bool {
        if(Cart.getCount() > 0) {
            if(Cart.sharedInstance[0].getRestaurantID() != self.restaurantID) {
                var valid: Bool = false
                let alert = UIAlertController(title: "Cart Item Conflict", message: "You can only add items from one restaurant. Would you like to clear your cart?", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    // Clear the cart
                    Cart.clearCart()
                    self.addItemToCard()
                    let someDict:[String:[CartItem]] = ["data": Cart.sharedInstance]
                    
                    // Push Notification to All Observers
                    NotificationCenter.default.post(name: Notification.Name("cartData"), object: nil, userInfo: someDict)
                    print("data pushed")
                    valid = true
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                    // Move back to restaurants screen
                    self.popViewController()
                    
                }))
                self.present(alert, animated: true)
                if (!valid) {return false}
            }
        }
        return true
    }
    
    func addItemAddedOverlay() {
        addOverlay()
        addCheckmark()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
            // move to prev screen
            self.popViewController()

        }
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addOverlay() {
        overlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height:  self.view.frame.height))

        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        self.view.addSubview(overlay)
    }
    
    func addCheckmark() {
        checkbox = M13Checkbox(frame: CGRect(x: (self.overlay.frame.width / 2) - 50 , y: self.overlay.frame.height / 2, width: 100, height: 100))
        
        // Animation duration
        checkbox?.animationDuration = 1.5
        
        // Checkbox style
        checkbox?.stateChangeAnimation = .bounce(.fill)
        checkbox?.tintColor = UIColor(red: 0, green: 70, blue: 0, alpha: 1)

        checkbox?.setCheckState(.checked, animated: true)
        self.overlay.addSubview(checkbox!)
    }
    /*

     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
