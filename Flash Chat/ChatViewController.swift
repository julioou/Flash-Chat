//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here

    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
//Atribuindo um array de mensagens
    var messageArray : [Message] = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        // Ligando os toques na tela
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        // Resgistrando, e localizando o arquivo XIB para customizar a celula da Table View
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
// UX design of Table View
        messageTableView.separatorStyle = .none
        
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
// Especificando e customizando a celula dentro da Table View,
// Adicionado imagem aos usuarios e definir estilo das células
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.messageBody.text = messageArray[indexPath.row].bodyMessage
        cell.avatarImageView.image = UIImage(named: "egg")
        
// Atualizar as cores conforme o usuário.
        if cell.senderUsername.text == (Auth.auth().currentUser?.email)! {
// Messagem que mandamos
            cell.avatarImageView.backgroundColor = UIColor.flatOrange()
            cell.messageBackground.backgroundColor = UIColor.flatNavyBlue()
            
        } else {
// Messagem que recebemos
            cell.avatarImageView.backgroundColor = UIColor.flatYellow()
            cell.messageBackground.backgroundColor = UIColor.flatForestGreenColorDark()
            
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2){
            self.heightConstraint.constant = 358
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error, reference) in
            
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                let alertContr = UIAlertController.init(title: "Sorry" , message: "We have some issue", preferredStyle: .alert)
                let alert = UIAlertAction.init(title: "Ok", style: .cancel, handler: .none)
                alertContr.addAction(alert)
                self.present(alertContr, animated: true, completion: nil)
            } else {
                print("Message save sucessfully")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                print("******************************************")
                print(messageDictionary)
                print("******************************************")
                SVProgressHUD.dismiss()
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    // Funcão para receber menssagens
    func retrieveMessages() {
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.bodyMessage = text
            message.sender = sender
            
            self.messageArray.append(message)
            
            self.configureTableView()
            
            self.messageTableView.reloadData()
            
        })
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show()
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            SVProgressHUD.dismiss()
            
        } catch {
            SVProgressHUD.dismiss()
            let alertContr = UIAlertController.init(title: "Sorry" , message: "There was a problem to siging out.", preferredStyle: .alert)
            let alert = UIAlertAction.init(title: "Ok", style: .cancel, handler: .none)
            
            alertContr.addAction(alert)
            self.present(alertContr, animated: true, completion: nil)
        }
        
    }
    
}
