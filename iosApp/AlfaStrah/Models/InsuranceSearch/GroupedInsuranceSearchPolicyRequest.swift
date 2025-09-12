//
//  GroupedInsuranceSearchPolicyRequest
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

struct GroupedInsuranceSearchPolicyRequest {
    let category: InsuranceCategory
    let requestsInfo: [RequestInfo]

    struct RequestInfo {
        let searchPolicyRequest: InsuranceSearchPolicyRequest
        let product: InsuranceSearchPolicyProduct
    }
}
