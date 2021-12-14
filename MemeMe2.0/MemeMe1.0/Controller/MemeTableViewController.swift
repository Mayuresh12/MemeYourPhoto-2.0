//
//  MemeTableViewController.swift
//  MemeMe1.0
//
//  Created by Mayuresh Rao on 12/11/21.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    //MARK: Properties
    let storyBoard : UIStoryboard = UIStoryboard(name: Constants.storyBoardId, bundle:nil)
    let delegate = UIApplication.shared.delegate as! AppDelegate


    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.title
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.memes.count
    }

    //MARK: tableview Datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath) as! MemeTableViewCell
        cell.memeImage.image = delegate.memes[indexPath.row].memedImage
        if let topText = delegate.memes[indexPath.row].topText,
           let bottomText = delegate.memes[indexPath.row].bottomText{
        cell.memeText.text = topText + "..." + bottomText
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        self.present(nextViewController, animated:true, completion: {
        })
    }
}

extension MemeTableViewController: CollectionDelegate {
    func memeViewDismissed() {
        self.tableView.reloadData()
    }
}

