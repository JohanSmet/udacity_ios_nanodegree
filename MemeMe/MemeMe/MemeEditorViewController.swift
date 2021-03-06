//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Johan Smet on 14/05/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate,
                                UITextFieldDelegate {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var memeView: UIView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // constants
    //
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2
    ]
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // initialize the fields when an existing meme is being edited
        if let memeIndex = self.memeIndex {
            let meme = appDelegate.memes[memeIndex]
            
            topText.text = meme.topText
            bottomText.text = meme.bottomText
            memeImage.image = meme.image
        }
    }

    override func viewWillAppear(animated: Bool) {
        
        // disable the camera button when no camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    
        // only enable the share button when the meme is complete
        shareButton.enabled = memeIsComplete()
        
        // make sure the meme textfields are formatted appropriately
        formatMemeTextField(topText)
        formatMemeTextField(bottomText)
        
        // subscribe to keyboard notifications to scroll the current textfield to the visible portion of the screen
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
        
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIImagePickerControllerDelegate overrides
    //
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

        // show the image picked by the user
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImage.image = image
        }
        
        // close the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // close the image picker
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UITextFieldDelegate overrides
    //
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }

    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // check the length of the new text
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        // if the new text is empty: disable the share button and exit
        if newText.length == 0 {
            shareButton.enabled = false
            return true;
        }
        
        // there's text in this field : enable the share button if the other conditions are also met
        if !shareButton.enabled {
            shareButton.enabled = memeIsComplete()
        }

        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // dismiss the keyboard when the enter key is pressed
        textField.resignFirstResponder()
        return false
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        // setup the image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        
        // present the image picker
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        // setup the image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // present the image picker
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelEditor(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        // generate a memed image
        let memedImage = generateMemedImage()
        
        // launch the ActivityViewController
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activityType, completed:Bool, returnItems:[AnyObject]!, activityError:NSError!) in
            // 'save' the meme to the shared model
            self.saveMeme(memedImage)
            
            // return to the sent memes view
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func tapGesture(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private func memeIsComplete() -> Bool {
    
        if memeImage!.image == nil {
            return false
        }
        
        if topText.text!.isEmpty  || bottomText.text!.isEmpty {
            return false
        }
        
        return true;
    }

    private func formatMemeTextField(p_field: UITextField) {
        p_field.defaultTextAttributes = memeTextAttributes
        p_field.textAlignment = NSTextAlignment.Center
        p_field.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        p_field.borderStyle = UITextBorderStyle.None
        p_field.delegate = self
        
        // attributed placeholder
        var f_attrs = memeTextAttributes
        f_attrs[NSForegroundColorAttributeName] = UIColor.grayColor()
        p_field.attributedPlaceholder = NSAttributedString(string:p_field.placeholder ?? "", attributes: f_attrs)
    }
    
    private func saveMeme(memedImage : UIImage) {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let memeIndex = self.memeIndex {
            // remove the original meme
            var meme = appDelegate.memes.removeAtIndex(memeIndex)
        }
        
        // create the meme
        var meme = Meme(topText: topText.text!, bottomText: bottomText.text!, image: memeImage.image!, memedImage: memedImage)
        
        // add it to the shared model
        appDelegate.memes.append(meme)
    }
    
    private func generateMemedImage() -> UIImage {
        
        // render view to an image
        UIGraphicsBeginImageContext(memeView.frame.size)
        let c = UIGraphicsGetCurrentContext();
        memeView.layer.renderInContext(c)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }

    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // keyboard height
        let kbHeight = getKeyboardHeight(notification)
        
        // update the insets of the scroll view
        let contentInsets:UIEdgeInsets  = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // check if the current control is outside the view or not
        if let activeTextField = self.activeTextField {
        
            var aRect: CGRect = self.view.frame
            aRect.size.height -= kbHeight
        
            if (!CGRectContainsPoint(aRect, activeTextField.frame.origin) ) {
                let scrollPoint:CGPoint = CGPointMake(0.0, activeTextField.frame.origin.y - kbHeight)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let kbHeight = getKeyboardHeight(notification)
     
        // reset the insets of the scroll view
        let contentInsets:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    private func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // member variables
    //
    
    var activeTextField : UITextField? = nil
    var memeIndex : Int?
    
}

