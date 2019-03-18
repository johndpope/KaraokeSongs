//
//  KaraokeSongsViewController.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit

protocol KaraokeSongsDisplayLogic: class
{
  func displayKaraokeSongs(viewModel: KaraokeSongs.KaraokeModels.ViewModel)
  func displayError(errorModel: KaraokeSongs.KaraokeModels.ErrorModel)
}

class KaraokeSongsViewController: UICollectionViewController, KaraokeSongsDisplayLogic
{
  var interactor: KaraokeSongsBusinessLogic?
  var router: (NSObjectProtocol & KaraokeSongsRoutingLogic & KaraokeSongsDataPassing)?
  var songs: [KaraokeSongs.KaraokeModels.KaraokeSong] = [KaraokeSongs.KaraokeModels.KaraokeSong]()
  var nextCall: String?
  var alreadyFetching: Bool = false
  let refreshControl = UIRefreshControl()
  var footerView : KaraokeSongsFooterView?
    
  // MARK: Object lifecycle
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = KaraokeSongsInteractor()
    let presenter = KaraokeSongsPresenter()
    let router = KaraokeSongsRouter()
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.refreshControl.beginRefreshing()
    doLoadSongs()
    setupUI()
  }
  
  // MARK: Do something
  
  func clearCollectionView(){
    if self.songs.count > 0{
        self.songs.removeAll()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
  }

    func stopRefreshControl(){
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
  //@IBOutlet weak var nameTextField: UITextField!
  @objc
  func doLoadSongs()
  {
    if self.refreshControl.isRefreshing == true {
        clearCollectionView()
        let request = KaraokeSongs.KaraokeModels.Request()
        interactor?.doFetchSongs(request: request)
    }
  }
    
    func doLoadNextSongs(){
        if self.alreadyFetching == false{
            self.alreadyFetching = true
            var request = KaraokeSongs.KaraokeModels.Request()
            request.nextCall = self.nextCall
            interactor?.doFetchNextSongs(request: request)
        }
    }
  
    func setupUI(){
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        self.view.tintColor = UIColor(hex: 0xed0000)

        collectionView.register(KaraokeSongCell.self, forCellWithReuseIdentifier: KaraokeSongCell.identifier)
        collectionView.register(KaraokeSongsFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: KaraokeSongsFooterView.identifier)

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.bounces = true
        collectionView.contentInset.bottom = 30
        
        refreshControl.addTarget(self, action: #selector(doLoadSongs), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width-40, height: 100)
        flowLayout.minimumLineSpacing = 15
        flowLayout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        flowLayout.footerReferenceSize = CGSize(width: collectionView.bounds.size.width, height: 55)

    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (self.songs.count-1){
            self.doLoadNextSongs()
        }
    }
    
    func displayKaraokeSongs(viewModel: KaraokeSongs.KaraokeModels.ViewModel){
        self.songs.append(viewModel.karaokeSongs!)
        self.nextCall = viewModel.nextCall
        self.alreadyFetching = false
        DispatchQueue.main.async {
            self.stopRefreshControl()
            self.footerView?.stopAnimate()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }

    func displayError(errorModel: KaraokeSongs.KaraokeModels.ErrorModel){
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let aFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: KaraokeSongsFooterView.identifier, for: indexPath) as! KaraokeSongsFooterView
        self.footerView = aFooterView
        self.footerView?.backgroundColor = UIColor.clear
        return aFooterView
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
            self.footerView?.startAnimate()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: KaraokeSongCell.identifier, for: indexPath) as? KaraokeSongCell else { return UICollectionViewCell() }
        let song = songs[indexPath.item]
//        item.imageView.image = alert.image
//        item.imageView.tintColor = alert.color
        item.title.text = song.trackName
//        item.subtitle.textColor = .darkGray
        return item
    }
}

class KaraokeSongCell: UICollectionViewCell {
    
    static let identifier = String(describing: KaraokeSongCell.self)
    
    public lazy var imageView: UIImageView = {
        $0.contentMode = .center
        return $0
    }(UIImageView())
    
    public lazy var title: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 17)
        $0.textColor = .black
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var subtitle: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 13)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    fileprivate let textView = UIView()
    
    //    let ls2 = LabelSwitchConfig(text: "Yes",
    //                                textColor: .white,
    //                                font: .boldSystemFont(ofSize: 20),
    //                                gradientColors: [UIColor.red.cgColor, UIColor.purple.cgColor], startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
    //
    //    let rs2 = LabelSwitchConfig(text: "No",
    //                                textColor: .white,
    //                                font: .boldSystemFont(ofSize: 20),
    //                                gradientColors: [UIColor.yellow.cgColor, UIColor.orange.cgColor], startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
    //
    //    public let gradientLabelSwitch = LabelSwitch(center: CGPoint(x: contentView.center.x, y: contentView.center.y + 100), leftConfig: ls2, rightConfig: rs2, defaultState: .L)
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = .white
        contentView.addSubview(imageView)
        contentView.addSubview(textView)
        //contentView.addSubview(gradientLabelSwitch)
        textView.addSubview(title)
//        textView.addSubview(subtitle)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        //Log("layoutMargins = \(layoutMargins), contentView = \(contentView.bounds)")
        layout()
    }
    
    func layout() {
//        let vTextInset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
//        let hTextInset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8
//        let imageViewHeight: CGFloat = contentView.height - (layoutMargins.top + layoutMargins.bottom)
//        imageView.frame = CGRect(x: layoutMargins.left + 4, y: layoutMargins.top, width: imageViewHeight, height: imageViewHeight)
//        let textViewWidth: CGFloat = contentView.width - imageView.frame.maxX - 2 * hTextInset
//        let titleSize = title.sizeThatFits(CGSize(width: textViewWidth, height: contentView.height))
//        let subtitleSize = subtitle.sizeThatFits(CGSize(width: textViewWidth, height: contentView.height))
        title.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.contentView.frame.size.width, height: 40))
//        subtitle.frame = CGRect(origin: CGPoint(x: 0, y: title.frame.maxY + vTextInset), size: CGSize(width: textViewWidth, height: subtitleSize.height))
//        textView.size = CGSize(width: textViewWidth, height: subtitle.frame.maxY)
//        textView.frame.origin.x = imageView.frame.maxX + hTextInset
//        textView.center.y = imageView.center.y
        //textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
        
//        style(view: contentView)
    }
    
    func style(view: UIView) {
        view.maskToBounds = false
        view.backgroundColor = .white
        view.cornerRadius = 14
        view.shadowColor = .black
        view.shadowOffset = CGSize(width: 1, height: 5)
        view.shadowRadius = 8
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 14, height: 14)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
    }
}


class KaraokeSongsFooterView : UICollectionReusableView{
    
    static let identifier = String(describing: KaraokeSongsFooterView.self)

    public lazy var loadingLabel: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 17)
        $0.textColor = .black
        $0.text = "Loading..."
        $0.textAlignment = .center
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    var isAnimatingFinal:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.myCustomInit()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.myCustomInit()
    }
    
    override func layoutSubviews() {
        loadingLabel.frame = self.frame
    }
    
    func myCustomInit() {
        self.addSubview(loadingLabel)
    }
    
    func setTransform(inTransform:CGAffineTransform, scaleFactor:CGFloat) {
        if isAnimatingFinal {
            return
        }
        self.loadingLabel.isHidden = true
    }
    
    //reset the animation
    func prepareInitialAnimation() {
        self.isAnimatingFinal = false
         self.loadingLabel.isHidden = false
    }
    
    func startAnimate() {
        self.isAnimatingFinal = true
        self.loadingLabel.isHidden = false
    }
    
    func stopAnimate() {
        self.isAnimatingFinal = false
        self.loadingLabel.isHidden = true
    }
}
