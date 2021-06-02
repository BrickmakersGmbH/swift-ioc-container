//
//  File.swift
//  
//
//  Created by Jonas Österle on 03/04/2020.
//

import Foundation
import Quick
import Nimble

import Swift_IoC_Container

protocol PIoCTestProtocol4 {}
protocol PIoCCanNotBeResolved {}

class IoCSpec: QuickSpec {
    override func spec() {
        describe("validateRegisteredConstructors") {
            
            class IoCTestClass: PIoCTestProtocol {}
            class LazyIoCTestClassWithError: PIoCTestProtocol4 {
                init(x: PIoCCanNotBeResolved = IoC.shared.resolveOrNil()!) {}
            }
            
            it("should not fail for valid constructors") {
                IoC.shared.registerLazySingleton(PIoCTestProtocol.self, IoCTestClass())
                expect(IoC.shared.validateRegisteredConstructors()).toNot(throwAssertion())
                
            }
            
            it("should throw for invalid constructors") {
                IoC.shared.registerLazySingleton(PIoCTestProtocol4.self, LazyIoCTestClassWithError())
                expect(IoC.shared.validateRegisteredConstructors()).to(throwAssertion())
                
            }
            
            it("should not throw if protocol is blacklisted") {
                class LazyIoCTestClassWithError: PIoCTestProtocol4 {
                    init(x: PIoCCanNotBeResolved = IoC.shared.resolveOrNil()!) {}
                }
                
                IoC.shared.registerLazySingleton(PIoCTestProtocol4.self, LazyIoCTestClassWithError())
                
                let blackList = [
                    ObjectIdentifier(PIoCTestProtocol4.self)
                ]
                
                expect(IoC.shared.validateRegisteredConstructors(blackList: blackList)).toNot(throwAssertion())
            }
            
        }
    }
}
