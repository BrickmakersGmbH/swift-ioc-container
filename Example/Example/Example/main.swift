import swift_ioc_container

protocol SuperAwesomeBot {
    func saySomething()
}

class StarWarsBot: SuperAwesomeBot {
    func saySomething() {
        print("The Force will be with you. Always.")
    }
}

class App {
    
    @Injected private var myBot: SuperAwesomeBot

    init() {
        IoC.shared.registerLazySingleton(SuperAwesomeBot.self, { StarWarsBot() })
    }
    
    func talkWithBot() {
        myBot.saySomething()
    }
}

// use the propertyWrapper
let app = App()
app.talkWithBot()

// resolving dependency on a regular property
let bot: SuperAwesomeBot = try! IoC.shared.resolve()
bot.saySomething()
