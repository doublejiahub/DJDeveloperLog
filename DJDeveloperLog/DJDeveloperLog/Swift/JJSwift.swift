//
//  JJSwift.swift
//  HJJLog
//
//  Created by haojiajia02 on 2021/1/28.
//

import Foundation
import UIKit

class Person: NSObject {
    var firstName: String
    var lastName: String
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    override func value(forUndefinedKey key: String) -> Any? {
        return "未知参数"
    }
}

class PersonController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let person = Person(firstName: "Tong", lastName: "Xiaotuo")
        print(person.firstName) //直接引用
        print(person.value(forKey: "firstName")!) //KVC的方式获得属性
        print(person.value(forKey: "xxx")!)//KVC中出现错误的key
        person.setValue("修改的名字", forKey: "firstName")
        print(person.value(forKey: "firstName")!)
    }
}


//官方的例子
class MyObjectToObserve: NSObject {
    dynamic var myDate = NSDate()
    func updateDate() {
        myDate = NSDate()
    }
}

private var myContext = 0
class MyObserver: NSObject {
    var objectToObserve = MyObjectToObserve()
    override init() {
        super.init()
        //为对象的属性注册观察者：对象通过调用下面这个方法为属性添加观察者
        objectToObserve.addObserver(self, forKeyPath: "myDate", options: .new, context: &myContext)
    }
    //观察者接收通知，并做出处理:观察者通过实现下面的方法，完成对属性改变的响应：

    /*keyPath: 被观察的属性，其不能为nil.
    object: 被观察者的对象.
    change: 属性值，根据上面提到的Options设置，给出对应的属性值
    context: 上面传递的context对象。*/
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let newValue = change?[NSKeyValueChangeKey.newKey] {
                print("Date changed: \(newValue)")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    //清除观察者:对象通过下面这个方法移除观察者：
    deinit {
        objectToObserve.removeObserver(self, forKeyPath: "myDate", context: &myContext)
    }
}
