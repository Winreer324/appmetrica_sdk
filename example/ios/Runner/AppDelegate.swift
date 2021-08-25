import UIKit
import Flutter
import YandexMobileMetrica

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let appmetricaChannel = FlutterMethodChannel(name: "com.medx.pro/appmetrica",
                                                     binaryMessenger: controller.binaryMessenger)
        
        
        appmetricaChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "activate":
                self?.handleActivate(result:result, call:call)
            case "setPurchase":
                self?.setPurchase(result:result, call:call)
            case _:
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "No impliment methord",
                                    details: nil))
            }
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    private func handleActivate(result: FlutterResult, call: FlutterMethodCall){
        
        guard  let args:  Dictionary<String, Any>?  = (call.arguments as! Dictionary<String, Any>)   else {
            result("iOS could not recognize flutter arguments in method: (sendParams)")
        }
              
        let apiKey: String = args!["apiKey"]! as! String
        let maxReportsInDatabaseCount:Int = args!["maxReportsInDatabaseCount"]! as! Int
        let sessionTimeout: Int = args!["sessionTimeout"]! as! Int
        let locationTracking: Bool = args!["locationTracking"]! as! Bool
        let statisticsSending: Bool =  args!["statisticsSending"]!  as! Bool
        let crashReporting: Bool = args!["crashReporting"]! as! Bool

        let configuration = YMMYandexMetricaConfiguration.init(apiKey: apiKey)
      
        configuration?.maxReportsInDatabaseCount = UInt(maxReportsInDatabaseCount)
        configuration?.sessionTimeout = UInt(sessionTimeout)
        configuration?.locationTracking = locationTracking
        configuration?.statisticsSending = statisticsSending
        configuration?.crashReporting = crashReporting
        YMMYandexMetrica.activate(with: configuration!)
         
        result("done init")
    }
    private func setPurchase(result: FlutterResult, call: FlutterMethodCall){
        
        guard  let args:  Dictionary<String, Any>?  = (call.arguments as! Dictionary<String, Any>)   else {
            result("iOS could not recognize flutter arguments in method: (sendParams)")
        }
              
        let courseId: String = args!["courseId"]! as! String
        let title: String = args!["title"]! as! String
        let price: Int = args!["price"]! as! Int
        let currency: String = args!["currency"]! as! String
       
        
//        // Creating a screen object.
        let screen = YMMECommerceScreen(
            name: "",
            categoryComponents: [],
            searchQuery: "",
            payload: [:]
        )
        // Creating an actualPrice object.
        let actualPrice = YMMECommercePrice(
            fiat: .init(unit: currency, value: .init(string: String(price)))
        )
        // Creating a product object.
        let product = YMMECommerceProduct(
            sku: courseId,
            name: title,
            categoryComponents: [],
            payload: [:],
            actualPrice: actualPrice,
            originalPrice: .init(
                fiat: .init(unit: currency, value: .init(string: String(price)))
            ),
            promoCodes: []
        )
//        // Creating a referrer object.
//        let referrer = YMMECommerceReferrer(type: "button", identifier: "76890", screen: screen)
//        // Creating a cartItem object.
        let addedItems = YMMECommerceCartItem(
            product: product,
            quantity: .init(string: "1"),
            revenue: actualPrice,
            referrer: YMMECommerceReferrer(type:"",identifier:"",screen:screen)
        )
//        // Creating an order object.
        let order = YMMECommerceOrder(
            identifier: courseId,
            cartItems: [addedItems]
        )
//        payload: ["black_friday": "true"]
        
//        java
//          ECommercePrice actualPrice = new ECommercePrice(new ECommerceAmount(price, currency));
        
//        ECommercePrice originalPrice = new ECommercePrice(new ECommerceAmount(price, currency));
//
//        ECommerceProduct product = new ECommerceProduct(courseId)
//                .setOriginalPrice(originalPrice)
//                .setPayload(payload)
//                .setName(title);
//
//        ECommerceCartItem addedItems = new ECommerceCartItem(product, actualPrice, 1);
//
//        ECommerceOrder order = new ECommerceOrder(courseId, Collections.singletonList(addedItems));
//        ECommerceEvent beginCheckoutEvent = ECommerceEvent.beginCheckoutEvent(order);
//
//
//        YandexMetrica.reportECommerce(beginCheckoutEvent);
//        ECommerceEvent purchaseEvent = ECommerceEvent.purchaseEvent(order);
//
//        YandexMetrica.reportECommerce(purchaseEvent);
//        YandexMetrica.sendEventsBuffer();
//         jave
        
        // Sending an e-commerce event.
        YMMYandexMetrica.report(eCommerce: .beginCheckoutEvent(order:order))
        YMMYandexMetrica.report(eCommerce: .purchaseEvent(order:order))
        YMMYandexMetrica.sendEventsBuffer()
//        YMMYandexMetrica.report(eCommerce: .beginCheckoutEvent(order:order), onFailure: nil)
//        YMMYandexMetrica.report(eCommerce: .purchaseEvent(order: order), onFailure: nil)
        //
        result("done")
    }
}
