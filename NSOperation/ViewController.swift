
//
//NSOperation和NSOperationQueue实现多线程的具体步骤
//
//先将需要执行的操作封装到一个NSOperation对象中
//然后将NSOperation对象添加到NSOperationQueue中
//系统会自动将NSOperationQueue中的NSOperation取出来
//将取出的NSOperation封装的操作放到一条新线程中执行
//2016

import UIKit

class ViewController: UIViewController {
    
    var queue1 = NSOperationQueue()
    var pressedBtn = false
    var block:NSBlockOperation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button1 = UIButton(frame: CGRectMake(30,30,100,100))
        button1.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        button1.setTitle("暂停闭包", forState: UIControlState.Normal)
        button1.backgroundColor = UIColor.greenColor()
        button1.addTarget(self, action: "suspend", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button1)
        
        let button2 = UIButton(frame: CGRectMake(30,150,100,100))
        button2.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        button2.setTitle("取消闭包", forState: UIControlState.Normal)
        button2.backgroundColor = UIColor.greenColor()
        button2.addTarget(self, action: "cancleBlock", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button2)
        
        
        let btn3:UIButton = UIButton(frame: CGRect(x: 30, y: 270, width: 100, height: 35))
        btn3.backgroundColor = UIColor.purpleColor()
        
        btn3.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn3.setTitle("取消队列", forState: UIControlState.Normal)
        btn3.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        
        let shape3:CAShapeLayer = CAShapeLayer()
        let bepath3:UIBezierPath = UIBezierPath()
        bepath3.moveToPoint(CGPoint(x: 0,y: 0))
        bepath3.addLineToPoint(CGPoint(x: 80,y: 0))
        
        bepath3.addLineToPoint(CGPoint(x: 100,y: 15))
        bepath3.addLineToPoint(CGPoint(x: 100,y: 35))
        bepath3.addLineToPoint(CGPoint(x: 0,y: 35))
        bepath3.closePath()
        
        shape3.path = bepath3.CGPath
        
        btn3.layer.mask = shape3
        self.view.addSubview(btn3)
        btn3.addTarget(self, action: "cancleQueue", forControlEvents: UIControlEvents.TouchUpInside)
    }
//闭包的暂停，只能暂停下一个闭包。当前闭包不受影响。
    func suspend(){
        pressedBtn = !pressedBtn
        if pressedBtn {
            queue1.suspended = true
            print(queue1.suspended)
        }else{
            queue1.suspended = false
            print(queue1.suspended)
        }
    }
//闭包的取消，只能取消队列中未执行的闭包。取消正在执行的，或是已经执行完的闭包，无效。
    func cancleBlock(){
        print("cancleBlock 已经按了")
        block.cancel()

    }
//队列的取消，也只能取消还未执行的闭包。正在执行的闭包不受影响。
    func cancleQueue(){
        print("cancleQueue 已经按了")
        queue1.cancelAllOperations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//最大线程并发数，而不是线程总数
        queue1.maxConcurrentOperationCount = 3
        
         block = NSBlockOperation.init { () -> Void in
            NSLog("1-----\(NSThread.currentThread())")
        
        }
        

//   又开一个新的线程
        block.addExecutionBlock { () -> Void in
            NSLog("5-----\(NSThread.currentThread())")
        }
        block.completionBlock = {print("闭包结束")}
//        当block用start启动时，block里面的都在主队列执行，也就主线程里面串行执行。addExecutionblock里面的都在另一个线程。
//        block.start()
       
//        加到非主线程queue时，block里面的都在相同的其中一个子线程中串行执行。executionblock里面的都在另一个线程。
        
//注意点3： NSOperationQueue.mainQueue().addOperation(block)。如果将block添加到主线程，block里面的在主线程中执行，而block.addExecutionBlock里面的却在子线程中执行。
        
//又开一个线程
        queue1.addOperationWithBlock { () -> Void in
            NSLog("101-----\(NSThread.currentThread())")
        }
        
        
//        创建依赖
        let block2 = NSBlockOperation.init { () -> Void in
            NSLog("10-----\(NSThread.currentThread())")
            sleep(3)
            NSLog("20-----\(NSThread.currentThread())")
        }
        
//      依赖必须在addOperation之前添加
        block.addDependency(block2)
        
        
        queue1.addOperation(block2)
        queue1.addOperation(block)
        
        
//设置NSOperation在queue中的优先级,可以改变操作的执⾏优先级
//(NSOperationQueuePriority)queuePriority;
//block.queuePriority = .VeryHigh
  
    }

    

}

