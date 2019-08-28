//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()
        
// Login the user
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
//Pop up to alert some problem with login
                SVProgressHUD.dismiss()
                let alertContr = UIAlertController.init(title: "Sorry" , message: "There was a problem to login.", preferredStyle: .alert)
                let alert = UIAlertAction.init(title: "Ok", style: .cancel, handler: .none)
                alertContr.addAction(alert)
                self.present(alertContr, animated: true, completion: nil)
               
                
            } else {
// Login sucessful
                SVProgressHUD.dismiss()
                print("*************************")
                print("Login sucessful!")
                print("*************************")
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
    }
    
}  
