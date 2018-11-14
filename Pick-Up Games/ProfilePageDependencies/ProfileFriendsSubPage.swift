//
//  ProfileFriendsSubPage.swift
//  Pick-Up Games
//
//  Created by David Otwell on 11/12/18.
//  Copyright © 2018 Amir Babaei. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileFriendsSubPage: UIViewController{

    @IBOutlet weak var myFriendsTable: UITableView!
    
    var friendsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myFriendsTable.delegate = self
        myFriendsTable.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllFriends { (returnedFriendsArray) in self.friendsArray = returnedFriendsArray.reversed()
            self.myFriendsTable.reloadData()
            
        }
    }
}
extension ProfileFriendsSubPage: UITableViewDelegate, UITableViewDataSource {
    
    func getAllFriends(handler: @escaping (_ friends: [String]) -> ()) {
        let userID = Auth.auth().currentUser?.uid
        let REF_PROF = Database.database().reference().child("users").child(userID!)
        let REF_USERS = Database.database().reference().child("users")
        REF_USERS.observeSingleEvent(of: .value) { (usersSnapshot) in
            guard let usersSnapshot = usersSnapshot.children.allObjects as? [DataSnapshot] else { return }
            
            for user in usersSnapshot {
                print(user.key)
                REF_PROF.child("Friends/\(user.key)").observeSingleEvent(of: .value, with: { (friendSnapshot) in
                    if (friendSnapshot.exists()) {
                        let name = user.childSnapshot(forPath: "Full Name").value as! String
                        if (!self.friendsArray.contains(name)) { self.friendsArray.append(name) }
                    }
                    self.myFriendsTable.reloadData()
                })
            }
        }
    }
    
    func numberOfSections(in myEventsTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell") as? FriendCell else { return UITableViewCell() }
        
        let image = UIImage(named: "test-login")
        let friend = friendsArray[indexPath.row]
        
        cell.fillCell(profPic: image!, name: friend)
        return cell
    }
    
}
