//
//  K.swift
//  Movie_RnR_iOS
//
//  Created by 엄태양 on 2022/07/17.
//

import Foundation

struct Constant {
    struct TableViewCellID {
        static let Posting = "PostingCell"
        static let Title = "TitleCell"
        static let Comment = "CommentCell"
        static let MyPageMenu = "MyPageMenuCell"
    }
    
    struct SegueID {
        static let detail = "goToDetail"
        static let login = "goToLogin"
        static let myPage = "goToMyPage"
        static let editProfile = "goToEditProfile"
        static let changePassword = "goToChangePassword"
        static let viewPostings = "goToViewPostings"
        static let dangerZone = "goToDangerZone"
        static let SNS = "goToSNS"
        static let Home = "goToHome"
        static let Join = "goToJoin"
    }
    
    struct MyPageMenu {
        static let list = [editProfile, changePassword, viewPostings, dangerZone]
        static let editProfile = "Edit Profile"
        static let changePassword = "Change Password"
        static let viewPostings = "View Postings"
        static let dangerZone = "Danger Zone"
    }
    
    static let serverURL = "http://127.0.0.1:8000"
    
    static let genderList = ["None","Man","Woman"]
}
