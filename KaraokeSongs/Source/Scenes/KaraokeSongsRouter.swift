//
//  KaraokeSongsRouter.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit

@objc protocol KaraokeSongsRoutingLogic
{
  //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol KaraokeSongsDataPassing
{
  var dataStore: KaraokeSongsDataStore? { get }
}

class KaraokeSongsRouter: NSObject, KaraokeSongsRoutingLogic, KaraokeSongsDataPassing
{
  weak var viewController: KaraokeSongsViewController?
  var dataStore: KaraokeSongsDataStore?
  
  // MARK: Routing
  
  //func routeToSomewhere(segue: UIStoryboardSegue?)
  //{
  //  if let segue = segue {
  //    let destinationVC = segue.destination as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //  } else {
  //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
  //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
  //    var destinationDS = destinationVC.router!.dataStore!
  //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
  //    navigateToSomewhere(source: viewController!, destination: destinationVC)
  //  }
  //}

  // MARK: Navigation
  
  //func navigateToSomewhere(source: KaraokeSongsViewController, destination: SomewhereViewController)
  //{
  //  source.show(destination, sender: nil)
  //}
  
  // MARK: Passing data
  
  //func passDataToSomewhere(source: KaraokeSongsDataStore, destination: inout SomewhereDataStore)
  //{
  //  destination.name = source.name
  //}
}
