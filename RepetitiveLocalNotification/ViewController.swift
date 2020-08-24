//
//  ViewController.swift
//  RepetitiveLocalNotification
//
//  Created by shin seunghyun on 2020/08/24.
//  Copyright © 2020 paige sofrtware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeNotifications()
  

        
    }
    
    func initializeNotifications() {
        let notificationService = NotificationService()
        notificationService.requestAuthorization(remote: true)
        notificationService.removePendingNotificationRequests()
        /// 여러 notification을 넣고 싶으면 다른 identifier를 넣으면 된다.

        guard let weekDay: Int = notificationService.getCurrentWeekDay() else {
            print("Day of Week")
            return
        }
        
        print("weekday: \(weekDay)")
        
        notificationService.setPeriodicNotificationsForThreeDays(notificationObject: NotificatinoObject(title: "Hello", body: "World"), startWeekday: weekDay - 1, startHour: 8, endHour: 21, hourInterval: 1, minuteInterval: 0)
        
        notificationService.getDeliveredNotificationRequests { (notifications) in
            print(notifications.count)
            for notification in notifications {
                print("***Delivered Noitifications***")
                print(notification)
            }
        }


        notificationService.getPendingNotificationRequests { (notifications) in
            print("***Pending Notifications***")
            print(notifications.count)
            var index: Int = 0
            for notification in notifications {
                print("index \(index) : " , notification.trigger!)
                index += 1
            }
            
        }

    }
    

}

