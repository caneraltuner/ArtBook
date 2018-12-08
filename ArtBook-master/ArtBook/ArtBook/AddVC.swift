//
//  AddVC.swift
//  ArtBook
//
//  Created by akademobi4 on 6.12.2018.
//  Copyright © 2018 enes. All rights reserved.
//

import UIKit
import CoreData

class AddVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var paintingText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var paintingYearText: UITextField!
    @IBOutlet weak var mainView: UIView!
    var chosenPainting = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenPainting != "" {
            let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting)
            fetchRequest.returnsObjectsAsFaults = false
            do {
               let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            paintingText.text = name
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            paintingYearText.text = String(year)
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }
                    }
                }
            } catch {
                
            }
        }
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(AddVC.selectImage))
        imageView.addGestureRecognizer(gesture)
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        print(chosenPainting)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        //Attributes
        newArt.setValue(artistText.text!, forKey: "artist")
        newArt.setValue(paintingText.text, forKey: "name")
        if let year = Int(paintingYearText.text!) {
            newArt.setValue(year, forKey: "year")
        }
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey: "image")
        do {
            try context.save()
            print("congrats")
        } catch {
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPainting"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
