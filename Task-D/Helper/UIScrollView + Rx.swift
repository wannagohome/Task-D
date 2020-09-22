//
//  UIScrollView + Rx.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIScrollView {
  var isReachedBottom: ControlEvent<Void> {
    let source = self.contentOffset
      .filter { [weak base = self.base] offset in
        guard let base = base else { return false }
        return base.contentOffset.y >= (base.contentSize.height - base.frame.size.height)
      }
      .map { _ in Void() }
    return ControlEvent(events: source)
  }
}
