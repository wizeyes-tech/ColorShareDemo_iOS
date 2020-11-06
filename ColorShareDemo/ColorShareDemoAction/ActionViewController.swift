//
//  ActionViewController.swift
//  Action不带视图Swift版本
//
//  Created by 番茄清单开发者 on 2019/5/18.
//  Copyright © 2019 番茄清单开发者. All rights reserved.
//

import UIKit
import MobileCoreServices

enum ActionType:Int {
    case Color
    case ColorTheme
    case Add
    case Start
    case Summary
}

class ActionViewController: UIViewController {
    @IBOutlet weak var noDataLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var found = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
			for itemProvider in item.attachments! {
                if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePlainText)) { //文本类型
                    itemProvider.loadItem(forTypeIdentifier: String(kUTTypePlainText), options: nil, completionHandler: { (item, error) in
                        OperationQueue.main.addOperation {
							if let text = item as? String {
								let textStr = text.replacingOccurrences(of: "\n", with: "")
								let data = textStr.data(using: String.Encoding.utf8)
								let dic = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
								self.handelAction(dic:dic as! NSDictionary)

							}
                        }
                    })
                    
                    found = true
                    break
                }
            }
            
            if (found) {
                break
            }
        }
        
        if !found {
            showNoDataView()
        }
    }
    
    private func showNoDataView() {
        noDataLabel.isHidden = false
    }
    

    @IBAction func done() {
        self.extensionContext?.completeRequest(returningItems: self.extensionContext?.inputItems ?? [], completionHandler: nil)
    }
    

    //MARK:私有
    private func handelAction(dic:NSDictionary) {
        if let colors = dic["colors"] as? NSArray {
			let colorString = colors.componentsJoined(by: "")
            let path = colorString.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'\"();:@&=+$,/?%#[]% ").inverted)!
            doOpenRoute(action: .ColorTheme, path: path)
        }
        else if let color = dic["HEX"] as? String {
            let path = color.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'\"();:@&=+$,/?%#[]% ").inverted)!
            doOpenRoute(action: .Color, path: path)
        }
    }
    
    private func doOpenRoute(action:ActionType,path:String) {
        switch action {
		//色卡主题导入
        case .ColorTheme:
            doOpenUrl(url: "colorShareDemo://color/theme/\(path)")
            break
		//单色导入
        case .Color:
            doOpenUrl(url: "colorShareDemo://color/single/\(path)")
            break
            
        default:
            print("还没想好")
        }
        
    }
    
    private func doOpenUrl(url: String) {
        let urlNS = NSURL(string: url)!
        var responder = self as UIResponder?
        while (responder != nil) {
            if responder?.responds(to: #selector(UIApplication.openURL(_:))) == true {
                responder?.perform(#selector(UIApplication.openURL(_:)), with: urlNS)
            }
	
            responder = responder!.next
        }

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.done()
        }
    }
}
