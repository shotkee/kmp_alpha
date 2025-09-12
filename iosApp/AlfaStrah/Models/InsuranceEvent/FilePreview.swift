//
//  FilePreview
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 22/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct FilePreview {
    // sourcery: transformer.name = "small_image_url", transformer = "UrlTransformer<Any>()"
    var smallImageUrl: URL?

    // sourcery: transformer.name = "big_image_url", transformer = "UrlTransformer<Any>()"
    var bigImageUrl: URL?

    // sourcery: transformer = "UrlTransformer<Any>()"
    var url: URL
}
