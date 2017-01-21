//
//  APIConstants.swift
//  IEQ
//
//  Created by Abel Anca on 12/8/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import Foundation

// Development URL
#if DEBUG
    //let K_API_MAIN_URL                                      = "http://06053440.ngrok.io/api/"
    let K_API_MAIN_URL                                      = "http://ieq-poc.cloudapp.net/api/"
    #else
    let K_API_MAIN_URL                                      = "http://ieq-poc.cloudapp.net/api/"
#endif

// API Constants
let k_API_User_Login                                    = "user/login"
let k_API_User_Register                                 = "user/register"
let k_API_User_RefreshToken                             = "user/refresh-token"

let k_API_Roles                                         = "route/get-system-roles"
let k_API_OrganizationTypes                             = "organization/get-organization-types"

let k_API_Question                                      = "question/get-system-questions"
let k_API_Answer                                        = "question/answer-question"

let k_API_GetOrganizationByLocation                     = "organization/get-organization-by-location"
let k_API_AddOrganization                               = "organization/insert-organization"
