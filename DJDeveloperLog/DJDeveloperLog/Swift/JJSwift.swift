//
//  JJSwift.swift
//  HJJLog
//
//  Created by haojiajia02 on 2021/1/28.
//

import Foundation
import UIKit

//Mark: try-catch
enum VendingMachineError: Error {
    case invalidSelection
    case insufficientFunds(coinsNeeded: Int)
    case outOfStock
}

struct Item {
    var price: Int
    var count: Int
}

class VendingMachine {
    var inventory = [
        "Candy Bar": Item(price: 12, count: 7),
        "Chips": Item(price: 10, count: 4),
        "Pretzels": Item(price: 7, count: 11)
    ]
    var coinsDeposited = 0

    func vend(itemNamed name: String) throws {
        guard let item = inventory[name] else {
            throw VendingMachineError.invalidSelection
        }

        guard item.count > 0 else {
            throw VendingMachineError.outOfStock
        }

        guard item.price <= coinsDeposited else {
            throw VendingMachineError.insufficientFunds(coinsNeeded: item.price - coinsDeposited)
        }

        coinsDeposited -= item.price

        var newItem = item
        newItem.count -= 1
        inventory[name] = newItem

        print("Dispensing \(name)")
        
        let age = -3
        assert(age >= 0, "A person's age cannot be less than zero")
        // 因为 age < 0，所以断言会触发
    }
}



class JJSwift {
    
    
    func optional() {
        ///The `Optional` type is an enumeration with two cases. `Optional.none` is
        /// equivalent to the `nil` literal. `Optional.some(Wrapped)` stores a wrapped
        /// value. For example:
        ///
        ///     let number: Int? = Optional.some(42)
        ///     let noNumber: Int? = Optional.none
        ///     print(noNumber == nil)
        ///     // Prints "true"
        
        /*
         @frozen public enum Optional<Wrapped> : ExpressibleByNilLiteral {

             /// The absence of a value.
             ///
             /// In code, the absence of a value is typically written using the `nil`
             /// literal rather than the explicit `.none` enumeration case.
             case none

             /// The presence of a value, stored as `Wrapped`.
             case some(Wrapped)
         */
        var possibleNumer: Optional<Any>?
        
        //Swift 的 nil 和 Objective-C 中的 nil 并不一样。在 Objective-C 中，nil 是一个指向不存在对象的指针。在 Swift 中，nil 不是指针——它是一个确定的值，用来表示值缺失。任何类型的可选状态都可以被设置为 nil，不只是对象类型。
        var number:Int? = nil
    }
    
    func tuples() {
        //元组
        let http200Status = (statusCode:200, description:"OK")
        print("The status code is \(http200Status.statusCode)")
        // 输出“The status code is 200”
        print("The status message is \(http200Status.description)")
        // 输出“The status message is OK”
    }
}


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
