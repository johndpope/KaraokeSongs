//
//  KaraokeSongsViewController.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit
import SwiftIcons

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
        navigationController?.navigationBar.tintColor = UIColor(hex: 0xff0500)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        self.view.tintColor = UIColor(hex: 0xff0500)
        
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
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width-40, height: 146)
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
        self.alreadyFetching = false
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            let alert = UIAlertController(title: errorModel.title, message: errorModel.message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
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
        assignCellValues(cell: item, model: song)
        item.lyricsButtonAction = { [unowned self] in
            let item = self.songs[indexPath.item]
            print(item)
            if let url = URL(string: item.originalLyricURL ?? "") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        return item
    }
    
    func assignCellValues( cell: KaraokeSongCell, model : KaraokeSongs.KaraokeModels.KaraokeSong){
        cell.title.text = model.title
        if model.imageUrl != nil{
            cell.imageView.load(url: model.imageUrl!, placeholder: nil)
        }
        cell.imageView.circleCorner = true
        cell.subtitle.text = model.altTitle
        cell.langCode.text = model.langCode
        cell.runtime.text = model.runtime
        cell.releaseDate.text = model.releaseDate
        cell.lyricsCount.text = model.lyricsCount
        cell.genres.text = model.genres
        cell.artistCount.text = model.artistCount
    }
}

class KaraokeSongCell: UICollectionViewCell {
    
    static let identifier = String(describing: KaraokeSongCell.self)
    
    var lyricsButtonAction : (() -> ())?
    
    public lazy var imageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.circleCorner = true
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor(hex: 0xff0500).cgColor
        $0.backgroundColor = .lightGray
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
    
    public lazy var langCode: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var runtime: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var releaseDate: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var lyricsCount: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var genres: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var artistCount: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 11)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    lazy var originalLyricURLButton: UIButton = {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.maskToBounds = true
        $0.cornerRadius = 25
        $0.setIcon(icon: .linearIcons(.musicNote), iconColor: UIColor(hex: 0xff0500), title: "Lyrics", titleColor: .black, font: .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 13), backgroundColor: .clear, borderSize: 1, borderColor: UIColor(hex: 0xff0500), forState: .normal)
        $0.addTarget(self, action: #selector(KaraokeSongCell.linkClick),
                     for: .touchUpInside)
        return $0
    }(UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50)))
    
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
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(langCode)
        contentView.addSubview(runtime)
        contentView.addSubview(releaseDate)
        contentView.addSubview(lyricsCount)
        contentView.addSubview(genres)
        contentView.addSubview(artistCount)
        contentView.addSubview(originalLyricURLButton)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    func layout() {
        imageView.frame = CGRect(x: layoutMargins.left + 4, y: layoutMargins.top, width: 50, height: 50)
        
        originalLyricURLButton.frame = CGRect(origin: CGPoint(x: layoutMargins.left + 4, y: layoutMargins.top+imageView.frame.size.height + 10), size: CGSize(width: 50, height: 50))
        imageView.circleCorner = true
        let imageMaxY = imageView.frame.origin.x + imageView.frame.size.width + layoutMargins.right
        var top = layoutMargins.top
        title.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 25))
        top += title.frame.height
        subtitle.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 20))
        top += 20
        releaseDate.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 15))
        top += 18
        langCode.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 15))
        top += 18
        lyricsCount.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 15))
        top += 15
        genres.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 15))
        top += 15
        artistCount.frame = CGRect(origin: CGPoint(x: imageMaxY, y: top), size: CGSize(width: self.contentView.frame.size.width - imageMaxY, height: 15))
        style(view: contentView)
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
    
    
    @objc func linkClick(indexButton : UIButton) {
        lyricsButtonAction?()
    }
}


class KaraokeSongsFooterView : UICollectionReusableView{
    
    static let identifier = String(describing: KaraokeSongsFooterView.self)
    
    public lazy var loadingLabel: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 17)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.isHidden = true
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
        self.loadingLabel.text = "Loading..."
        self.isAnimatingFinal = false
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
