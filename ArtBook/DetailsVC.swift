//
//  DetailsVC.swift
//  ArtBook
//
//  Created by Yasemin YEL on 18.01.2021.
//  Copyright © 2021 Sifa. All rights reserved.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
     var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        useDATA()
   hideKeyboard()
// hide keyboard recognizer
//        let gestureRecegnizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(gestureRecegnizer)
        
    //select image recognizer
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
         imageView.addGestureRecognizer(imageTapRecognizer)
    }
    func useDATA() {
        if chosenPainting != "" {
               //core data
               //saveButton.isEnabled = false
               saveButton.isHidden = true
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               let context = appDelegate.persistentContainer.viewContext
               
               let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
               let idString = chosenPaintingId?.uuidString
               
               fetchReguest.predicate = NSPredicate(format: "id = %@", idString!)
               fetchReguest.returnsObjectsAsFaults = false
               
               do {
                   let results = try context.fetch(fetchReguest)
                   if results.count > 0 {
                       for result in results as! [NSManagedObject] {
                           if let name = result.value(forKey: "name") as? String {
                               nameText.text = name
                           }
                           if let artist = result.value(forKey: "artist") as? String {
                               artistText.text = artist
                           }
                           if let year = result.value(forKey: "year") as? Int {
                               yearText.text = String(year)
                           }
                           if let imageData = result.value(forKey: "image") as? Data {
                               let image = UIImage(data: imageData)
                               imageView.image = image
                           }
                       }
                   }
                   
                   }
                   catch {
                   print("error")
               }
              
               }
               else {
               saveButton.isHidden = false
               saveButton.isEnabled = false
                   nameText.text = ""
                   yearText.text = ""
                   artistText.text = ""
                   
               }
        
    }
   // hide keyboard
//    @objc func hideKeyboard () {
//        view.endEditing(true)
//    }
    @objc func selectImage() {
         let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = .photoLibrary                //select where/how
           picker.allowsEditing = true                     // editing
           present(picker, animated: true, completion: nil)
       }
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           imageView.image = info[.originalImage] as? UIImage
           saveButton.isEnabled = true
           self.dismiss(animated: true, completion: nil)
       }
    @IBAction func buutonClicked(_ sender: Any) {
     
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributs
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        if let year = Int(yearText.text!) {
         newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5) //SAVE %
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
            }
        catch {
                print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true) //geri gelmeyi sağlıyor resmi kayd.sonra
    }
    
}
