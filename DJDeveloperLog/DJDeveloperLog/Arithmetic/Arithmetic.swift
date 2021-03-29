//
//  Arithmetic.swift
//  DJDeveloperLog
//
//  Created by haojiajia02 on 2021/3/22.
//

import Foundation

class Arithmetic : NSObject {
    class func execute() {
        let arithmetic =  Arithmetic()
        let nums = [-2,1,-3,4,-1,2,1,-5,4]
        let maxNumsSum = arithmetic.maxSubArrayGreed(nums)
        print("最大值:\(maxNumsSum)")
        
        let mulStr = arithmetic.multiply("123", "45")
        print("字符串乘积: \(mulStr)")
        let digits = "123".map{Int(String($0))!}
        print("字符串转数组：\(digits)")
        
        let constArr = [3,8,-1,59,-7,-1,66,5,-26,100,25,1200,-12,83,66]
        print("原数组: \(constArr)")

        var quickArr = constArr//[6,1,2,5,9,3,4,7,10,8]
        arithmetic.quickSort(&quickArr, left: 0, right: quickArr.count-1)
        print("快排后: \(quickArr)")

        if let mergeArr = arithmetic.mergeSort(constArr) {
            print("归并后: \(mergeArr)")
        }

        var arr = [4,3,2,1]
        let median = arithmetic.findMedian(&arr, count: arr.count)
        print("中位数: \(median)")

    }
}

//MARK: 最大子字符串
extension Arithmetic {
    //动态规划
    func maxSubArrayDynamic(_ nums: [Int]) -> Int {
        var sumNums = nums
        for i in 1..<sumNums.count {
            if sumNums[i-1] > 0 {
                sumNums[i] += sumNums[i-1]
            }
        }
        print(sumNums)
        return sumNums.max() ?? 0
    }
    
    //贪心算法
    func maxSubArrayGreed(_ nums: [Int]) -> Int {
        var sum = 0
        var result = nums[0]
        for i in 0..<nums.count {
            if sum > 0 {
                sum += nums[i]
            }else {
                sum = nums[i]
            }
            result = max(sum, result)
        }
        return result
    }
}


//MARK: 字符串相乘
extension Arithmetic {
    func multiply(_ num1: String, _ num2: String) -> String {
        print(num1)
        print(num2)
        if num1 == "0" || num2 == "0" {
            return "0"
        }

        let arr1 = num1.compactMap { Int(String($0)) }
        let arr2 = num2.compactMap { Int(String($0)) }

        var res = [Int](repeating: 0, count: arr1.count + arr2.count)
        for i in (0..<arr1.count).reversed() {
            for j in (0..<arr2.count).reversed() {
                var mul = arr1[i] * arr2[j]
                let p1 = i+j
                let p2 = i+j+1
                print("\(arr1[i]) * \(arr2[j]) = \(mul)")
                print("res: \(res)")
                mul += res[p2]
                print("十位: \(res[p1]) 个位: \(res[p2]) mul: \(mul)")
                res[p1] += mul / 10 //这次的高位需要加上次的高位
                res[p2] = mul % 10 //低位一直在往前走,所以不用加上次的值
                print("res: \(res)\n")
                //链接：https://leetcode-cn.com/problems/multiply-strings/solution/gao-pin-mian-shi-xi-lie-zi-fu-chuan-cheng-fa-by-la/
            }
            print(res)
        }

        var str = ""
        var i = res[0] > 0 ? 0 : 1
        for _ in i..<res.count {
            str += String(res[i])
            i += 1
        }
        return str
    }
    
    func stringToArray(_ str : String) -> [Int] {
        let characterArray = Array(str)
        var integerArray = [Int]()
        for character in characterArray {
            let unitScalar = character.unicodeScalars.first!.value - Unicode.Scalar("0").value
            integerArray.append(Int(unitScalar))
        }
        return integerArray
    }

}


//MARK: 栈实现队列


//MARK: 字符串反转
extension Arithmetic {
    func reverseString(_ str : inout String) -> String {
        guard str.count > 1 else {
            return str
        }
        var characters = str.map { String($0) }
        var i = 0
        var j = characters.count - 1
        while i < j {
            characters.swapAt(i, j)
            i += 1
            j -= 1
        }
        str = characters.joined()

        return str
    }
}

//MARK: 链表反转
//Definition for singly-linked list.
public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}

extension Arithmetic {
    func reverseList(_ head: ListNode?) -> ListNode? {
        if head == nil || head?.next == nil {
            return head
        }
        
        var p = head
        //newHead 是 "头指针"
        var newHead: ListNode?
        
        while p != nil {
            //记录下一个节点
            let tmp = p?.next
            //当前节点的 next 指向新链表的头部
            p?.next = newHead
            //更改新链表的头部为当前节点
            newHead = p
            //移动 p 指针
            p = tmp
        }
        return newHead
    }
}


//MARK: 快排
extension Arithmetic {
    func quickSort<T:Comparable>(_ arr: inout [T], left: Int, right: Int) {
        if left < right {
            let p = partition(&arr, left: left, right: right)
            quickSort(&arr, left: 0, right: p-1)
            quickSort(&arr, left: p+1, right: right)
        }
    }
    
    func partition<T:Comparable>(_ arr: inout [T], left: Int, right: Int) -> Int {
        let pivot = arr[left]
        var i = left
        var j = right
        
        while i != j {
            //循环找到右边比 pivot 小的
            while i < j && arr[j] >= pivot {
                j -= 1
            }
            
            while i < j && arr[i] <= pivot {
                i += 1
            }
            
            //左边找到大数,右边找到小数,两个条件都满足才能走到这
            if (i < j) {
                arr.swapAt(i, j)
            }
        }
        
        //交换 left 和相遇位 i/j(现在 i == j)
        //pivot 相当于 temp
        arr[left] = arr[i]
        arr[i] = pivot
        
        return i
    }
    
}


//MARK: 归并
extension Arithmetic {
    func mergeSort<T:Comparable>(_ arr: [T]) -> [T]? {
        var tempArr = [[T]]()
        for item in arr {
            let subArr = [item]
            tempArr.append(subArr)
        }
        
        while tempArr.count != 1 {
            var i = 0
            while i < tempArr.count - 1 {
                tempArr[i] = mergeArr(leftArr: tempArr[i], rightArr: tempArr[i+1])
                tempArr.remove(at: i+1)
                i += 1
            }
        }
        
        return tempArr.first
    }
    
    func mergeArr<T:Comparable>(leftArr: [T], rightArr: [T]) -> [T] {
        var mergeArr = [T]()
        mergeArr.reserveCapacity(leftArr.count + rightArr.count)
        var i = 0
        var j = 0
        while i < leftArr.count && j < rightArr.count {
            if leftArr[i] < rightArr[j] {
                mergeArr.append(leftArr[i])
                i += 1
            }else {
                mergeArr.append(rightArr[j])
                j += 1
            }
        }
        
        //把剩下的按序归位
        //两段 while 只有一个会执行
        while i < leftArr.count {
            mergeArr.append(leftArr[i])
            i += 1
        }
        
        while j < rightArr.count {
            mergeArr.append(rightArr[j])
            j += 1
        }
        
        print("mergeArr: \(mergeArr)")
        return mergeArr
    }
    
}


//MARK: 无序数组中位数
extension Arithmetic {
   func findMedian(_ arr: inout [Int],count: Int) -> Int {
       let i = 0
       let j = count - 1

       let mid = (count - 1)/2
       var p = partSort(&arr,left: i,right: j)
       while (p != mid) {
           if (mid < p) {
              p = partSort(&arr,left: i,right: p-1)
           }else {
              p = partSort(&arr,left: p+1,right: j)
           }
       }
       return arr[mid]
   }

   func partSort(_ arr: inout [Int],left: Int, right: Int) -> Int {
       var i = left
       var j = right

       let pivot = arr[i]
       while(i != j) {
           while (i<j && arr[j]>pivot) {
               j -= 1
           }
           while (i<j && arr[i]<pivot) {
               i += 1
           }
           if (i < j) {
               let temp = arr[i]
               arr[i] = arr[j]
               arr[j] = temp
           }
       }

       arr[i] = arr[left]
       arr[left] = pivot
    
       return i
   }
    
}


//MARK: 最大子序和
extension Arithmetic {
    func maxSubArray(_ nums: inout [Int]) {
        //边界条件判断，当i等于0的时候，也就是前1个元素，他能构成的最大和也就是他自己，所以
        var result = nums[0]
        var sum : Int = 0
        //如果 num 小于0，我们直接把前面的舍弃，也就是说重新开始计算，否则会越加越小的，直接让dp[i]=num[i]
        for num in nums {
           if sum > 0{
               sum += num
           }else{
               sum = num
           }
            result = max(result, sum)
            print("ans:\(result) --- sum:\(sum)")
        }
        print(result)
    }
}

//MARK: 判断是否为合法IP
extension Arithmetic {
    func validIPAddress(_ IP: String) -> String {
        guard !IP.isEmpty else {
            return "Neither"
        }
        
        if IP.contains(":") {
            return validIPV6Address(IP)
        } else if IP.contains(".") {
            return validIPV4Address(IP)
        } else {
            return "Neither"
        }
        
    }
    func validIPV4Address(_ IP: String) -> String {
        let ipv4Chunk = "([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])"
        let regexStr = "^(" + ipv4Chunk + "\\.){3}" + ipv4Chunk + "$"
        let ret = RegularExpression(regex: regexStr, validateString: IP)
        if !ret.isEmpty {
            return "IPv4"
        } else {
            return "Neither"
        }
        
    }
    func validIPV6Address(_ IP: String) -> String {
        let ipv6Chunk = "([0-9a-fA-F]{1,4})"
        let regexStr = "^(" + ipv6Chunk + "\\:){7}" + ipv6Chunk + "$"
        let ret = RegularExpression(regex: regexStr, validateString: IP)
        if !ret.isEmpty {
            return "IPv6"
        } else {
            return "Neither"
        }
    }
    func RegularExpression (regex:String,validateString:String) -> [String]{
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: validateString, options: [], range: NSMakeRange(0, validateString.count))
            
            var data:[String] = Array()
            for item in matches {
                let string = (validateString as NSString).substring(with: item.range)
                data.append(string)
            }
            
            return data
        }
        catch {
            return []
        }
    }

    //作者：karl9102
    //链接：https://leetcode-cn.com/problems/validate-ip-address/solution/swift-zheng-ze-jie-fa-by-karl9102/
    //来源：力扣（LeetCode）
    //著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

}


//MARK: 知乎面试题
let NumberChineseDict = [0:"零",1:"壹", 2: "贰", 3: "叁",4:"肆", 5:"伍", 6:"陆",7:"柒", 8:"捌",9:"玖"]
let ZeroChineseDict = [1:"",2:"拾",3:"佰",4:"仟",5:"万",6:"百万",7:"千万",8:"亿"]
extension Arithmetic {
    func executeZhihu() {
//        let str1 = numberToChinese(num: 37)
//        let str2 = numberToChinese(num: 108)
//        let str3 = numberToChinese(num: 100)
//        let str4 = numberToChinese(num: 110)
//        let str5 = numberToChinese(num: 1000)
//        let str6 = numberToChinese(num: 100000)
//        let str7 = numberToChinese(num: 1040600)
//        let str8 = numberToChinese(num: 10709000)
        let str9 = numberToChinese(num: 10000001)

        findMaxCommonSubStr(["ABC", "BCD", "BCUYT"])
//        findMaxCommonSubStr(["ABCDF", "BCD", "BCUDYT"])
//        findMaxCommonSubStr(["ACDF", "BCD", "BCUCDYT"])
    }
    
    //1. 转换1亿以内的数字为中文表示(无小数), 比如 叁拾柒元正, 壹佰零捌元正
    func numberToChinese(num: NSInteger) -> String {
        guard num > 0 && num < 10000000 else {
            print("数字: \(num) ---- 请输入 1 亿内数字")
            return "请输入 1 亿内数字"
        }
        let numStr = String(num) //"13465653"
        let numArr = numStr.compactMap { Int(String($0)) }
        var str = ""
        for i in 0..<numArr.count {
            let num = numArr[i]
            let unit = ZeroChineseDict[numArr.count-i] ?? ""
            let number = NumberChineseDict[num] ?? ""
            if num == 0 {
                str += number
            }else {
                str += (number + unit)
            }
        }
        for char in str.reversed() {
            if char == "零" {
                str.removeLast()
            }else {
                break
            }
        }
        
        str += "元"
        print("数字: \(num) ---- \(str)")
        return str
    }
    //1. 转换1亿以内的数字为中文表示(无小数), 比如 叁拾柒元正, 壹佰零捌元正
    //2. 输出给字符串数组中, 所有元素的最大公共子符串(区分大小写), 没有时返回空, 如 "ABC", "BCD", "BCUYT", 输出 "BC"
    func findMaxCommonSubStr(_ strArr: [String]) -> String {
        guard strArr.count > 0 else {
            return ""
        }
        guard let str1 = strArr.first, str1 != "" else {
            return ""
        }
        var commonSubStr = ""
        for char in str1 {
            var isCommonChar = true
            for str in strArr[1..<strArr.count] {
                let newCommonChar = commonSubStr + String(char)
                if !str.contains(newCommonChar) {
                    isCommonChar = false
                    break
                }
            }
            if (isCommonChar) {
                commonSubStr += String(char)
            }else {
                if commonSubStr != "" {
                    break
                }
            }
        }
        print("公共子字符串: \(commonSubStr)")
        return commonSubStr
    }
    
}
