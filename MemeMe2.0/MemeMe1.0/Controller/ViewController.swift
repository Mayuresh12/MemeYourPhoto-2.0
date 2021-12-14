//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by Mayuresh Rao on 11/30/21.
//

import UIKit

protocol CollectionDelegate {
    func memeViewDismissed()
}

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate & UINavigationControllerDelegate,
                      UITextFieldDelegate {
    
    var del: CollectionDelegate?
    
    //MARK: Outlets
    
    @IBOutlet var memeImage: UIImageView!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var cameraButtonOutlet: UIBarButtonItem!
    @IBOutlet var topToolBar: UIToolbar!
    @IBOutlet var bottomToolBar: UIToolbar!
    @IBOutlet var shareButtonOutet: UIBarButtonItem!
    
    //MARK: Properties
    
    var memedImage: UIImage!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0
    ]
    
    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var isShareButtonEnabled: Bool {
        return !topTextField.text!.isEmpty &&
            !bottomTextField.text!.isEmpty &&
            memeImage.image != nil
        
    }
    
    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        subscribTokeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribTokeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButtonOutlet.isEnabled = isCameraAvailable
    }
    
    //MARK: Actions
    
    @IBAction func cancelButton(_ sender: Any) {
        configureUI()
        self.dismiss(animated: true, completion: nil)
    }
    
    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func imagePicker(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        var image = UIImage()
        image = generateMemedImage()
        let imagePicker = UIActivityViewController(activityItems: [image],
                                                   applicationActivities: nil)
        self.present(imagePicker, animated: true, completion: nil)
        imagePicker.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?,
                                                    completed: Bool,
                                                    arrayReturnedItems: [Any]?,
                                                    error: Error?) in
            if completed {
                //UnHide top toolBar and bottom toolBar
                self.topToolBar.isHidden = false
                self.bottomTextField.isHidden = false
                self.save()
                self.del?.memeViewDismissed()
                return
            }
            
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
    }
    
    //MARK: Configure UI
    func configureUI(){
        setupTextField(textField: topTextField, text: "TOP")
        setupTextField(textField: bottomTextField, text: "BOTTOM")
    }
    
    func setupTextField(textField: UITextField, text: String) {
        clearBottomTextField()
        clearTopTextField()
        memeImage.image = nil
        textField.placeholder = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        shareButtonOutet.isEnabled = isShareButtonEnabled
    }
    
    //MARK: Delegate methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
                                [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        memeImage.image = selectedImage
        shareButtonOutet.isEnabled = isShareButtonEnabled
        dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shareButtonOutet.isEnabled = isShareButtonEnabled
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        shareButtonOutet.isEnabled = isShareButtonEnabled
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func subscribTokeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    
    func unsubscribTokeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ViewController {
    //MARk: Util functions
    
    func save() {
        
        // Create the meme
        let meme = Meme(topText: topTextField.text!,
                 bottomText: bottomTextField.text!,
                 originalImage: memeImage.image,
                 memedImage: memedImage)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func generateMemedImage() -> UIImage {
        
        //Hide top toolBar and bottom toolBar
        topToolBar.isHidden = true
        bottomTextField.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        
        memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    
    func clearTopTextField() {
        topTextField.text =  nil
    }
    
    func clearBottomTextField() {
        bottomTextField.text =  nil
    }
    
}
