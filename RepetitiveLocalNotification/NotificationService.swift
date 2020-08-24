//
//  NotificationService.swift
//  RepetitiveLocalNotification
//
//  Created by shin seunghyun on 2020/08/24.
//  Copyright © 2020 paige sofrtware. All rights reserved.
//

import UserNotifications
import UIKit

//Weekly, Three Days Local Notifcation Reservation
class NotificationService: NSObject {
    
    let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    
        
    }
    
    func requestAuthorization(remote: Bool) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error: Error = error {
                print("error: ", error.localizedDescription)
                return
            }
            if granted {
                print("granted: ", granted)
                if remote {
                    print("Registered for remote message")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    func setPeriodicNotification(title: String, body: String, weekday: Int, hour: Int, minute: Int, categoryIdentifier: String?) {
         
        if minute > 60 {
            print("minute should be under 60")
            return
        }
        
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
//        content.sound = UNNotificationSound.init(named:UNNotificationSoundName(rawValue: "123.mp3"))
        
        var identifier: String = UUID().uuidString
        //만약 custom action을 추가하고 싶다면..
        if let categoryIdentifier: String = categoryIdentifier {
            identifier = categoryIdentifier
        }
        content.categoryIdentifier = identifier //identifier는 유저가 지정해주거나 UUID임.
        
        
        var dateComponents: DateComponents = DateComponents()
//        dateComponents.calendar = Calendar.current
        /// 1 - sunday, 2 - monday, ...... 7 - sunday
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        
        
        let request: UNNotificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if let error: Error = error {
                print("error: ", error.localizedDescription)
                return
            }
            print("added notification: \(request.identifier)")
        }
        
    }
    
    //MARK: 최대 64개까지만 저장 가능
    ///일주일치가 64개 미만일 때 아래 함수를 사용
    //일주일치 notification을 설정해줌
    //30분마다, 1시간마다, 2시간마다 alaram을 던질지 설정해줄 수 있음
    //startHour ...... endHour 사이에 1시간마다, 1시간 30분마다, 2시간마다 알림을 던지게 만듬
    func setPeriodicNotificationsForWeek(notificationObject: NotificatinoObject, startHour: Int, endHour: Int, hourInterval: Int, minuteInterval: Int) {
        
        if hourInterval > 3 {
            print("setPeriodicNotificationsForWeek(): hour should be between 1 - 3")
            return
        }
        
        if minuteInterval > 60 {
            print("setPeriodicNotificationsForWeek(): minute should be under 60")
            return
        }
        
        guard let totalIntervalCounts: Int = getTotalIntervalCounts(startHour: startHour, endHour: endHour, hourInterval: hourInterval, minuteInterval: minuteInterval) else {
            print("Can't get total interval!")
            return
        }
        //일주일치 notification
        for weekday in 1 ... 7 {
            //하루를 몇 번으로 나눌 것인지.
            for interval in 0 ... totalIntervalCounts {
                let title: String = notificationObject.title
                let body: String = notificationObject.body
                let start: Int = startHour + interval * hourInterval
                
                let minute: Int = minuteInterval
                print("weekday: \(weekday)")
                if let cateogoryIdentifier: String = notificationObject.categoryIdentifier {
                    setPeriodicNotification(title: title, body: body, weekday: weekday, hour: start, minute: minute, categoryIdentifier: cateogoryIdentifier)
                } else {
                    setPeriodicNotification(title: title, body: body, weekday: weekday, hour: start, minute: minute, categoryIdentifier: nil)
                }
            }
        }
    }
    
    //MARK: 최대 64개까지만 저장 가능
    ///일주일치가 64개가 넘을 때 사용
    func setPeriodicNotificationsForThreeDays(notificationObject: NotificatinoObject, startWeekday: Int, startHour: Int, endHour: Int, hourInterval: Int, minuteInterval: Int) {
        
        if hourInterval > 3 {
            print("setPeriodicNotificationsForWeek(): hour should be between 1 - 3")
            return
        }
        
        if minuteInterval > 60 {
            print("setPeriodicNotificationsForWeek(): minute should be under 60")
            return
        }
        
        guard let totalIntervalCounts: Int = getTotalIntervalCounts(startHour: startHour, endHour: endHour, hourInterval: hourInterval, minuteInterval: minuteInterval) else {
            print("Can't get total interval!")
            return
        }
        
        for count in 0 ... 2 {
            //하루를 몇 번으로 나눌 것인지.
            for interval in 0 ... totalIntervalCounts {
                let title: String = notificationObject.title
                let body: String = notificationObject.body
                let start: Int = startHour + interval * hourInterval
                let minute: Int = minuteInterval
                let day: Int = startWeekday + count
                if day <= 7 {
                    print("weekday: \(day)")
                    setPeriodicNotification(title: title, body: body, weekday: day, hour: start, minute: minute, categoryIdentifier: nil)
                } else if day == 8 {
                    print("weekday: \(1)")
                    setPeriodicNotification(title: title, body: body, weekday: 1, hour: start, minute: minute, categoryIdentifier: nil)
                } else if day == 9 {
                    print("weekday: \(2)")
                    setPeriodicNotification(title: title, body: body, weekday: 2, hour: start, minute: minute, categoryIdentifier: nil)
                }
            }
        }
    }
    
    //hour interval로 시작시간과 끝나는시간에 interval이 얼마나 있는지 구해줌
    private func getTotalIntervalCounts(startHour: Int, endHour: Int, hourInterval: Int, minuteInterval: Int = 0) -> Int? {
        
        if hourInterval > 3 {
            print("getTotalIntervalCounts(): hour should be between 1 - 3")
            return nil

        }
        
        if minuteInterval > 60 {
            print("getTotalIntervalCounts(): minute should be under 60")
            return nil
        }
        
        var intervalCounts: Int = 0 //하루에 총 몇 번의 interval이 있는지 계산
        
        var start: Int = startHour * 60 //시작 시간
        let end: Int = endHour * 60 //끝나는 시간
        
        let hour: Int = hourInterval * 60
        let minute: Int = minuteInterval
        
        if minute > 0 {
            while end > start + minute {
                if intervalCounts == 0 {
                    intervalCounts += 1
                    print("Current Count: \(intervalCounts)")
                    print("Reserved Time: \(start / 60) : \(minute)")
                }
                start += hour
                if end > start + minute {
                    intervalCounts += 1
                    print("Current Count: \(intervalCounts)")
                    print("Reserved Time: \(start / 60) : \(minute)")
                }
            }
            print("Total Hour Intervals: \(intervalCounts)")
        } else {
            while end >= start + minute {
                if intervalCounts == 0 {
                    intervalCounts += 1
                    print("Current Count: \(intervalCounts)")
                    print("Reserved Time: \(start / 60) : \(minute)")
                }
                start += hour
                if end >= start + minute {
                    intervalCounts += 1
                    print("Current Count: \(intervalCounts)")
                    print("Reserved Time: \(start / 60) : \(minute)")
                }
            }
            print("Total Hour Intervals: \(intervalCounts)")
        }
        return intervalCounts
    }
    
    func getCurrentWeekDay() -> Int? {
        return Date().dayNumberOfWeek()
    }
    
    //notification status
    func getPendingNotificationRequests() -> [UNNotificationRequest]? {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var notificationRequests: [UNNotificationRequest] = [UNNotificationRequest]()
        notificationCenter.getPendingNotificationRequests { (requests) in
            notificationRequests = requests
            semaphore.signal()
        }
        semaphore.wait()
        return notificationRequests
    }
    
    func getPendingNotificationRequests(completion: @escaping([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { (requests) in
            completion(requests)
        }
    }
    
   
    func getDeliveredNotificationRequests() -> [UNNotification]? {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var notificationRequests: [UNNotification] = [UNNotification]()
        notificationCenter.getDeliveredNotifications { (requests) in
            notificationRequests = requests
            semaphore.signal()
        }
        semaphore.wait()
        return notificationRequests
    }
    
    func getDeliveredNotificationRequests(completion: @escaping([UNNotification]) -> Void) {
        notificationCenter.getDeliveredNotifications { (requests) in
            completion(requests)
        }
    }
    
    func removePendingNotificationRequests(identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removePendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func clearDeliveredNotificationRequests(identifiers: [String]) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func clearDeliveredNotificationRequests() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
     
//        switch response.actionIdentifier {
//        case "Good":
//            label.text = "Lecture was Good"
//        case "Not Good":
//            label.text = "Lecture wasn't that bad"
//        default:
//            break
//        }
        
    }
    
    
}

struct NotificatinoObject {
    
    let title: String
    let body: String
    var hour: Int = 0
    var minute: Int = 0
    var categoryIdentifier: String? = nil
    
}

extension Date {
    
    func dayNumberOfWeek() -> Int? {
        return Calendar(identifier: .gregorian).dateComponents([.weekday], from: self).weekday 
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    

    
}
