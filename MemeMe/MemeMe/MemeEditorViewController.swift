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
                                UINavigationControllerDelegate {

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // outlets
    //
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var memeImage: UIImageView!
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // UIViewController overrides
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        
        // disable the camera button when no camera is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    
        // only enable the share button when the meme is complete
        shareButton.enabled = memeIsComplete()
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
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private func memeIsComplete() -> Bool {
        // TODO: complete == image + two text fields filled in
        return false
    }


}

