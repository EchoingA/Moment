//
//  File.swift
//  moment
//
//  Created by Allen Wu on 25/03/2024.
//

import Foundation
import UIKit

//list all the possibilities

enum MessageModelType: String{
    case text = "TextCell"//only text
    case image = "ImageCell"//only one iamge
    case MutiImage = "MutiImageCell"//for mutiple images
    case new = "NewCell"
    case video = "VideoCell"
    case ad //advertisement
}



class MessageModel:NSObject{
    
    var name = "halo"
    var modelType: MessageModelType!
    var contentText:String!
    
    init(type: MessageModelType){
        super.init()
        modelType = type
        self.configData()
    }
    
    func configData() -> Void{
        
    }
    
    private var _contextSize:CGSize!
    

    var contextSize:CGSize{
        
        if contentText == nil{
            return CGSize.zero
        }
        if _contextSize != nil{
            return _contextSize
        }
        
        _contextSize = contentText.textSize(size: CGSize(
            width:MomentConfigPara.maxWidth,height:CGFloat.greatestFiniteMagnitude),font: MomentConfigPara.textFont)
//        guard let contentText = contentText else {
//                return CGSize.zero
//            }
//            
//            if _contextSize == nil {
//                _contextSize = contentText.textSize(size: CGSize(
//                    width: MomentConfigPara.maxWidth, height: CGFloat.greatestFiniteMagnitude), font: MomentConfigPara.textFont)
//            }
        
        return _contextSize
        }
    
    
//////////
    var nameSize: CGSize {
            let size = name.textSize(size: CGSize(width: MomentConfigPara.maxWidth, height: CGFloat.greatestFiniteMagnitude), font: MomentConfigPara.textFont);
            return size;
        }
            
    var topHeight: CGFloat {
        let ht = (contextSize.height + 8) + nameSize.height + 12;
        return ht;
//        let ht = contextSize.height + nameSize.height + 14;
//        return ht < 60 ? 60 : ht;
    }
    private var _cHeight: CGFloat = 0;
    var commentHeight: CGFloat {
        if comment == nil || comment.count == 0 {
            return 0;
        }
        if _cHeight != 0 {
            return _cHeight;
        }
        
        for (_,item) in comment.enumerated() {
            _cHeight += (item.size.height + 4)
        }
        _cHeight += 20;
        return _cHeight;
    }
    
    var rowHeight: CGFloat {
        return topHeight + commentHeight + 6;
    }
    
    
    var comment: [CommentModel]!
 

    
}

class CommentModel: NSObject {
    var person: CommentItemModel! // one who comments
    var endPeseron: CommentItemModel! // // person who is commented
    
    var content = "";
    
    private let reply = "回复";
    
    private let highlitedDict = [NSAttributedString.Key.foregroundColor:UIColor.red];
    
    
    private var _size: CGSize!;
    var size: CGSize {
        if _size != nil {
            return _size;
        }
        let size = getContentText().boundSize();
        _size = size;
        return _size;
    }
    
    
    var endRange: NSRange? {
        if endPeseron != nil {
            return NSRange(location: pmRange.upperBound + reply.count, length: endPeseron.name.count);
        }
        return nil;
    }
    
    //get the range of person
    var pmRange: NSRange {
        return NSRange(location: 0, length: person.name.count);
    }
    
    
    private var contentAttribute: NSAttributedString!
    func getContentText() -> NSAttributedString {
        if contentAttribute != nil {
            return contentAttribute;
        }

        if endRange == nil {
            let attribute = NSMutableAttributedString(string: person.name + "：" + content);
            attribute.addAttributes(highlitedDict, range: pmRange);
            contentAttribute = attribute;
            return attribute;
            
        }else {
            
            let attribute = NSMutableAttributedString(string: person.name + reply + endPeseron.name + "：" + content);
            attribute.addAttributes(highlitedDict, range: pmRange);
            attribute.addAttributes(highlitedDict, range: endRange!);
            contentAttribute = attribute;
            return attribute;
        }
        
    }

    
    
    
}

class TextModel: MessageModel {
    
}

class CommentItemModel: NSObject {
    var name = ""; //name
    var id = ""; // usrname id
    var profile = ""// avatar
    

}



extension NSAttributedString {
    func boundSize() -> CGSize {
        
        if let size = RelationManager.value(key: mainKey) as? CGSize {
            return size;
        }
        let size = boundingRect(with: CGSize(width: MomentConfigPara.maxWidth - 8, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading,.usesLineFragmentOrigin], context: nil).size;
        RelationManager.setKey(key: mainKey, value: size);
        return size;
    }
    var mainKey: String {
        return string.MD5String;
    }
}

class ImageModel: MessageModel {
    var urlString = "";
    var image = UIImage(named: "1.jpg");
    
    override var topHeight: CGFloat {
        let ht = super.topHeight;
        return ht + 200;
    }
    var supHeight: CGFloat {
        return super.topHeight;
    }
}


class MultiImageModel: MessageModel {
    var images: [UIImage]!
    var count = 8 {
        didSet{
            count = count > 8 ? 8: count;
            images.removeAll();
            for idx in 0...count {
                images.append(UIImage(named: "\(idx).jpg")!);
            }
        }
    }

    
    override func configData() {
        images = [UIImage]();
        for idx in 0...count {
            if let image = UIImage(named: "\(idx).jpg") {
                images.append(image)
            } else {
                print("Failed to load image \(idx).jpg")
            }

            //images.append(UIImage(named: "\(idx).jpg")!);
        }
    }
    
    //for square images, height=width
    override var topHeight: CGFloat {
        if images == nil {
            return super.topHeight;
        }
        let perWidth = (MomentConfigPara.maxWidth - 8 - 40) / 3 + 4;
        let row = ceil(Double(images.count) / 3.0)
        return super.topHeight + perWidth * CGFloat(row);
    }
    
    var supTopHeight: CGFloat {
        return super.topHeight;
    }
    
    var cellImageHeight: CGFloat {
        return topHeight - super.topHeight;
    }
}






