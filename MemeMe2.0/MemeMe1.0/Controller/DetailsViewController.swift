//
//  DetailsViewController.swift
//  MemeMe1.0
//
//  Created by Mayuresh Rao on 12/13/21.
//

import UIKit

class DetailsViewController: UIViewController {
    //MARK: Outlets

    @IBOutlet var memeImage: UIImageView!
    var receivedImage : UIImage?
    
    //MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        memeImage.image = receivedImage
    }
    
    //MARK: Actions

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
