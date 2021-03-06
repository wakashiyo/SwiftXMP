//
//  ViewController.swift
//  Demo
//
//  Created by 吉川昂広 on 2018/09/29.
//  Copyright © 2018年 takahiro yoshikawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func tapButton(_ sender: Any) {
        createCamera()
    }
    
    func createCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker, animated: true, completion: nil)
        } else {
            print("cannot use camera")
        }
    }
    
    //撮影終了後に呼び出される
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imgData = UIImageJPEGRepresentation(image, 1.0)
            
            let random = Int(arc4random_uniform(10))
            print("random : \(random)")
            if random <= 2 {
                print("export jpg file")
                exportJpgFile(data: imgData!)
            } else if 3 <= random && random <= 6 {
                print("_export jpg file")
                _exportJpgFile(data: imgData!)
            } else {
                print("exportJpgFileAfterExif")
                exportJpgFileAfterExif(data: imgData!)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func exportJpgFile(data: Data) {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = path + "/sample.jpg"
        do {
            try data.write(to: URL(fileURLWithPath: path))
            
            let xmp = Xmp.xmp()
            let swiftXmp = SwiftXMP()
            
            switch swiftXmp.embedXmp(contens: URL(fileURLWithPath: path), xml: xmp) {
            case .success(let d):
                try d.write(to: URL(fileURLWithPath: path))
                print("add xmp successfully")
            case .failed(let e):
                print("add xmp error : \(e.localizedDescription)")
            }
        } catch let e {
            print("data write error : \(e.localizedDescription)")
        }
    }
    
    func _exportJpgFile(data: Data) {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = path + "/_sample.jpg"
        let xmp = Xmp.xmp()
        let swiftXmp = SwiftXMP()
        let _data = swiftXmp.embedXmp(contens: data, xml: xmp)
        
        do {
            try _data.write(to: URL(fileURLWithPath: path))
            print("add xmp successfully")
        } catch let e {
            print("data write error : \(e.localizedDescription)")
        }
    }
    
    func exportJpgFileAfterExif(data: Data) {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = path + "/dest.jpg"
        do {
            try data.write(to: URL(fileURLWithPath: path))
            
            Exif.exif(path: path)
            
            let xmp = Xmp.xmp()
            let swiftXmp = SwiftXMP()

            switch swiftXmp.embedXmp(contens: URL(fileURLWithPath: path), xml: xmp) {
            case .success(let d):
                try d.write(to: URL(fileURLWithPath: path))
                print("add xmp successfully")
            case .failed(let e):
                print("add xmp error : \(e.localizedDescription)")
            }
            
        } catch let e {
            print("error : \(e.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

