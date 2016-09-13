//
//  PhotoSelectViewController.swift
//  PicturesToChoose
//
//  Created by bocai on 16/9/13.
//  Copyright © 2016年 bocai. All rights reserved.
//

import UIKit
private let FJCollectionViewCellReuseIdentifier = "FJCollectionViewCellReuseIdentifier"
class PhotoSelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
    }

    func setupUI(){
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView])
        view.addConstraints(cons)
    }
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
       let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoSelectViewLayout())
        clv.registerClass(PhotoSelectorCell.self, forCellWithReuseIdentifier: FJCollectionViewCellReuseIdentifier)
        clv.dataSource = self
        return clv
    }()
/// 存储选择图片的数组
    private lazy var pictureImages = [UIImage]()
    
    

}

extension PhotoSelectViewController:UICollectionViewDataSource,PhotoSelectorCellDelegate ,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return pictureImages.count + 1
        return pictureImages.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FJCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! PhotoSelectorCell
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.image = (pictureImages.count == indexPath.item) ? nil : pictureImages[indexPath.item]
        cell.PhotoCellDelegate = self
        return cell
        
    }
    
    func photoDidAddSelector(cell: PhotoSelectorCell) {
//        print(__FUNCTION__)
        /*
        case PhotoLibrary     照片库(所有的照片，拍照&用 iTunes & iPhoto `同步`的照片 - 不能删除)
        case SavedPhotosAlbum 相册 (自己拍照保存的, 可以随便删除)
        case Camera    相机
        */
        
        if !UIImagePickerController.isSourceTypeAvailable( UIImagePickerControllerSourceType.PhotoLibrary) {
            print("不能打开相机")
        }
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        presentViewController(vc, animated: true, completion: nil)

    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        /*
        注意: 1.如果是通过JPEG来压缩图片, 图片压缩之后是不保真的
              2.苹果官方不推荐我们使用JPG图片,因为现实JPG图片的时候解压缩非常消耗
        */
        let newImage = image.imageWithScale(300)
        
        pictureImages.append(newImage)
        collectionView.reloadData()
        
        //注意:如果实现了该方法，需要我们自己关闭图片选择器
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func photoDidRemoveSelector(cell: PhotoSelectorCell) {
//        print(__FUNCTION__)
        let indexPath = collectionView.indexPathForCell(cell)
        pictureImages.removeAtIndex(indexPath!.item)
        collectionView.reloadData()
    }
}
//在Swift中如果让协议是可选的，需要在协议前面添加 @objc
@objc
protocol PhotoSelectorCellDelegate : NSObjectProtocol{
    optional func photoDidAddSelector(cell: PhotoSelectorCell)
    optional func photoDidRemoveSelector(cell: PhotoSelectorCell)
}

class PhotoSelectorCell: UICollectionViewCell {
    var image:UIImage?{
        didSet{
            if image != nil{
                removeButton.hidden = false
                addButton.userInteractionEnabled = false
                addButton.setBackgroundImage(image, forState: UIControlState.Normal)
            }else{
                removeButton.hidden = true
                addButton.userInteractionEnabled = true
                addButton.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
            }
            
            
        }
    }
    
    weak var PhotoCellDelegate:PhotoSelectorCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    
    private func setupUI(){
        contentView.addSubview(addButton)
        contentView.addSubview(removeButton)
        //布局子控件
        addButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[addButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addButton":addButton])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[addButton]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["addButton":addButton])
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:[removeButton]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["removeButton":removeButton])
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-2-[removeButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["removeButton":removeButton])
        
        contentView.addConstraints(cons)
    }
    
    
    //MARK: - 懒加载cell上子控件
    private lazy var removeButton:UIButton = {
       let btn = UIButton()
        btn.hidden = true
        btn.setBackgroundImage(UIImage(named: "compose_photo_close"),forState: UIControlState.Normal)
        btn.addTarget(self, action: "removeBtnAction", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    private lazy var addButton:UIButton = {
       let btn = UIButton()
        btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        btn.setBackgroundImage(UIImage(named: "compose_pic_add" ), forState: UIControlState.Normal)
        btn.addTarget(self, action: "addBtn", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    func removeBtnAction(){
        PhotoCellDelegate?.photoDidRemoveSelector!(self)
        
    }
    
    func addBtn(){
        PhotoCellDelegate?.photoDidAddSelector!(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoSelectViewLayout: UICollectionViewFlowLayout {
    /**
     准备布局
     */
    override func prepareLayout() {
        super.prepareLayout()
        itemSize = CGSize(width: 80, height: 80)
        //水平方向间距
        minimumInteritemSpacing = 10
        //竖直方向间距
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
    
    
}
