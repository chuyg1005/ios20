//
//  ViewController.swift
//  ShoppingTracker
//
//  Created by shiba on 2020/11/12.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

class ShoppingItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: properties
    @IBOutlet weak var nameTextField: UITextField!  // 文本框
    @IBOutlet weak var photoImageView: UIImageView!  // 图像
    @IBOutlet weak var descTextView: CustomizedTextView!  // 文本区域
    @IBOutlet weak var saveButton: UIBarButtonItem! // 保存按钮
    var shoppingItem: ShoppingItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        descTextView.delegate = self
        
        if let item = shoppingItem {
            nameTextField.text = item.name
            photoImageView.image = item.image
//            descTextView.text = item.desc
            descTextView.setText(text: item.desc)
            
        }
    }

    @IBAction func selectImageFromLibrary(_ sender: Any) {
        nameTextField.resignFirstResponder()
        descTextView.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: imagePickerControllerDelegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("miss error when select an image from photo library")
        }
        photoImageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    // 跳转到另外一个视图
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            return
        }
        
        let name = nameTextField.text ?? ""
        let image = photoImageView.image
        let desc = descTextView.text ?? ""
        
        shoppingItem = ShoppingItem(name: name, image: image, desc: desc)
    }
    
    // 退回上一个视图
    @IBAction func cancel(_ sender: Any) {
        let isPresentingInAddItemMode = presentingViewController is UINavigationController
        if isPresentingInAddItemMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("this view is not inside a navigation controller")
        }
    }
}

extension ShoppingItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text!)
    }
}

extension ShoppingItemViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print(textView.text!)
    }
}
