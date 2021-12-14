//
//  MemeCollectionViewController.swift
//  MemeMe1.0
//
//  Created by Mayuresh Rao on 12/11/21.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: Properties
    let storyBoard : UIStoryboard = UIStoryboard(name: Constants.storyBoardId, bundle:nil)
    let delegate = UIApplication.shared.delegate as! AppDelegate

    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        cell.memeImage.image = delegate.memes[indexPath.row].memedImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: Constants.detailViewControllerId) as! DetailsViewController
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.receivedImage = delegate.memes[indexPath.row].memedImage
        self.present(nextViewController, animated:true, completion: nil)
    }
    
    //MARK: Actions

    @IBAction func memeImageTapped(_ sender: Any) {
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: Constants.memeViewControllerId) as! ViewController
        nextViewController.del = self
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion: nil)
    }
}

extension MemeCollectionViewController: CollectionDelegate {
    func memeViewDismissed() {
        self.collectionView.reloadData()
    }
    
    func ConfigureUI(){
        let space:CGFloat = 1.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        navigationItem.title = Constants.title
    }
}
