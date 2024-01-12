//
//  UserFormViewController.swift
//  foodie
//
//  Created by Raiyan Z. Jugbhery on 2021-04-09.
//

import UIKit

class UserFormViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var customerNameInput: UITextField!
    @IBOutlet weak var customerPhoneInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var customerEmailInput: UITextField!

    public var restaurants = [Restaurant]()
    var orders = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRestaurants()
        customerPhoneInput.delegate = self
        customerNameInput.delegate = self
        customerEmailInput.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
            return UserDefaults.standard.object(forKey: key) != nil
        }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
    
        var restaurantN = ""
        var restaurantPhone = ""
        for each in restaurants{
            if (each._id == Cart.restaurant_id){
                restaurantN = each.name
                restaurantPhone = each.phone
                break
            }
        }
        
        let userDefaults = UserDefaults.standard
        
        if(isKeyPresentInUserDefaults(key: "PastUserOrders")) {
        // exists
            orders = userDefaults.object(forKey: "PastUserOrders") as! [[String]]
        }else {
        // doesn't exists
            UserDefaults.standard.set(orders, forKey: "PastUserOrders")
        }
    
        
        let date = Date()

        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"

        // Convert Date to String
        let order_Date = dateFormatter.string(from: date)
        
        let orderNumber = String(orders.count + 1)
        
        let orderTotalVal = String(format: "%.2f", Cart.calculateTotal())
        
        if (customerNameInput.text == "" || customerPhoneInput.text == "" || customerEmailInput.text == "" || Cart.isEmpty())
        {
            let dialogMessage = UIAlertController(title: "Alert", message: "Please fill out all user forms to complete order, or add items to cart", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             })
            //Add OK button to a dialog message
            dialogMessage.addAction(ok)
            // Present Alert to view
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else
        {
            //let newOrder = Order(userName: customerNameInput.text!, userPhone: customerPhoneInput.text!, userEmail: customerEmailInput.text!, restaurantName: restaurantN, orderTotal: orderTotalVal, orderDate: order_Date, orderID: orderNumber, restaurantNumber: restaurantPhone)
            
            var newOrder: [String]
            newOrder = [customerNameInput.text!, customerPhoneInput.text!, customerEmailInput.text!, restaurantN, orderTotalVal, order_Date, orderNumber, restaurantPhone]
            
            orders.append(newOrder)
            userDefaults.set(orders, forKey: "PastUserOrders")
            print("Printing all orders saved below")
            for each in orders{
                print(each)
            }
            
            //PastOrders.sharedInstance.append(newOrder)
            
            //let someDict:[String:[Order]] = ["data": PastOrders.sharedInstance]
            
            let someDict:[String:[[String]]] = ["data": orders]
            
            
            
            // Push Notification to All Observers
            NotificationCenter.default.post(name: Notification.Name("OrderData"), object: nil, userInfo: someDict)
            print("data pushed")
            
            Cart.clearCart()
            
            let cartDict:[String:[CartItem]] = ["data": Cart.sharedInstance]
            
            // Push Notification to All Observers
            NotificationCenter.default.post(name: Notification.Name("cartCleared"), object: nil, userInfo: cartDict)
            print("cart cleared")
            
            let dialogMessage = UIAlertController(title: "Order Processing", message: "The restaurant will contact you by phone or email for order pickup, or you can contact them to arrange a pickup.", preferredStyle: .alert)
            
            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                   // Code you want to be delayed
                    self.performSegue(withIdentifier: "showOrdersModal", sender: self)
                }
                
             })
            
            //Add OK button to a dialog message
            dialogMessage.addAction(ok)
            // Present Alert to view
            self.present(dialogMessage, animated: true, completion: nil)
            
            customerNameInput.text = ""
            customerPhoneInput.text = ""
            customerEmailInput.text = ""
            
            
        }
        
    }
    
    func resignKeyboard(){
        customerNameInput.resignFirstResponder()
        customerEmailInput.resignFirstResponder()
        customerPhoneInput.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true;
    }
    
    @IBAction func screentapped(_ sender: Any) {
        resignKeyboard()
    }
    
    func getRestaurants() {
        let url = URL(string: "https://onlyfoodsapi.herokuapp.com/restaurants")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response , error) in
            
            guard let data = data, error == nil else {
                print("Error")
                return
            }
            
            var result: [Restaurant]
            do {
                result = try JSONDecoder().decode([Restaurant].self, from: data)
                
                DispatchQueue.main.async {
                    self.restaurants = result
                    
                }
            } catch {
                print("Failed to convert")
            }
            
        })
        task.resume()
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
