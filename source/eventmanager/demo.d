module eventmanager.demo;

import std.exception;
import std.stdio;

import eventmanager.abstractevent;
import eventmanager.eventlistenerinterface;
import eventmanager.eventinterface;
import eventmanager.eventdispatcher;
import eventmanager.eventlist;

struct AppStartedMeta
{
    string appName;
}

struct UserCreatedMeta
{
    uint userId;
    string firstName;
    string lastName;
}

class AppStartedEvent : AbstractEvent!AppStartedMeta
{
    this(string appName)
    {
        AppStartedMeta meta;
        meta.appName = appName;

        super(meta);
    }
}

class UserCreatedEvent : AbstractEvent!UserCreatedMeta
{
    this(uint userId, string firstName, string lastName)
    in {
        enforce(userId > 0, "UserId must be greater than 0");
        enforce(firstName != "", "Please supply a valid first Name");
        enforce(lastName != "", "Please supply a valid last Name");
    } body {
        UserCreatedMeta meta;
        meta.userId = userId;
        meta.firstName = firstName;
        meta.lastName = lastName;

        super(meta);
    }
}

class UserUpdatedEvent : AbstractEvent!UserCreatedMeta
{
    this(uint userId, string firstName, string lastName)
    in {
        enforce(userId > 0, "UserId must be greater than 0");
        enforce(firstName != "", "Please supply a valid first Name");
        enforce(lastName != "", "Please supply a valid last Name");
    } body {
        UserCreatedMeta meta;
        meta.userId = userId;
        meta.firstName = firstName;
        meta.lastName = lastName;

        super(meta);
    }
}

class Listener1 : EventListenerInterface
{
    // Listener1 is interested only in the AppStartedEvent, but could be as
    // many different events as you want.
    public TypeInfo[] getInterestedEvents() {
        return [
            typeid(AppStartedEvent)
        ];
    }

    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) {
        writeln("Listener1 received event: ", event);

        auto eventList = new EventList();

        if (eventType == typeid(AppStartedEvent)) {
            auto meta = event.getMetadata();
            AppStartedMeta appStartedMeta = *meta.peek!(AppStartedMeta);
            writeln(appStartedMeta);
        }

        return eventList;
    }
}

class Listener2 : EventListenerInterface
{
    // Listener2 is interested in the UserCreatedEvent and UserUpdatedEvent events.
    public TypeInfo[] getInterestedEvents() {
        return [
            typeid(UserCreatedEvent),
            typeid(UserUpdatedEvent)
        ];
    }

    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) {
        writeln("Listener2 received event: ", event);

        auto eventList = new EventList();

        if (eventType == typeid(UserCreatedEvent)) {
            auto meta = event.getMetadata();
            UserCreatedMeta userCreatedMeta = *meta.peek!(UserCreatedMeta);
            writeln(userCreatedMeta);

            // Demonstrate creating another event within an event handler
            auto UserUpdatedEvent = new UserUpdatedEvent(userCreatedMeta.userId, userCreatedMeta.firstName, userCreatedMeta.lastName);
            eventList.append(UserUpdatedEvent, typeid(UserUpdatedEvent));

        } else if (eventType == typeid(UserUpdatedEvent)) {
            auto meta = event.getMetadata();
            UserCreatedMeta userCreatedMeta = *meta.peek!(UserCreatedMeta);
            writeln(userCreatedMeta);
        }

        return eventList;
    }
}

void beginDemo()
{
    // Create a few test events of different types
    auto eventAppStarted = new AppStartedEvent("My Test App");
    auto eventUserCreated = new UserCreatedEvent(1, "Jane", "Doe");
    
    // Setup event dispatcher and attach listeners
    auto dispatcher = new EventDispatcher();
    dispatcher.attachListener(new Listener1());
    dispatcher.attachListener(new Listener2());

    // Setup event list and append our test events.
    auto eventList = new EventList();
    eventList.append(eventAppStarted, typeid(AppStartedEvent));
    eventList.append(eventUserCreated, typeid(UserCreatedEvent));

    // Dispatch our events - the listeners should receive only the events they
    // are interested in.
    eventList.dispatch(dispatcher);

    // Show the lifecycle of each of the events
    writeln(eventAppStarted.getLifecycle());
    writeln(eventUserCreated.getLifecycle());
}