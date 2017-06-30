# EventManager

This library implements a variant of the publisher / subscriber pattern, using events, an event list and an event dispatcher.

## Usage Overview

Here's the basic pattern in use.  Your app may produce "events" (which can hold any metadata that you like), 
and you can then define listeners that will handle those events.

```
// Create a few test events of different types
auto eventAppStarted = new AppStartedEvent("My Test App");
auto eventUserCreated = new UserCreatedEvent(1, "Jane", "Doe");

// Setup an event dispatcher and attach listeners
auto dispatcher = new EventDispatcher();
dispatcher.attachListener(new Listener1());
dispatcher.attachListener(new Listener2());

// Setup an event list and append our test events.
auto eventList = new EventList();
eventList.append(eventAppStarted, typeid(AppStartedEvent));
eventList.append(eventUserCreated, typeid(UserCreatedEvent));

// Dispatch our events - the listeners should receive only the events they
// are interested in.
eventList.dispatch(dispatcher);

// At this point our event Listeners will receive the events they are subsribed to.
```

## Why

The benefit of setting up events and event listeners is that you separate commands and actions from the business logic associated with them.
This makes your code modular and more atomic in nature.  It also sets you up to implement [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html)

Somre more explanation about Events, Event Listeners and setting up the appropriate classes / structs follows.

## Events

Your app can raise events.  Events can store any metadata you like in structs.
An event must extend AbstractEvent and have a metadata struct type defined.

Here's an example of a metadata struct.  This struct can hold any number of properties of any type.  You could for example hold an entity or database tuple here.

```
struct UserCreatedMeta
{
    uint userId;
    string firstName;
    string lastName;
}
```

And here's an example of an event that contains that struct.

```
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
```

Events will be processed or handled by "listeners".

## Event Listeners

Event Listeners must declare the types of events they are interested in.  Moreover, they
and responsible for "handling" each event type via the "handleEvent" method.

A listener can be any D class so long as it implements the EventListenerInterface.

Here's an example of an event listener.

```
class Listener2 : EventListenerInterface
{
    // Listener2 is interested in the UserCreatedEvent and UserUpdatedEvent events.
    public TypeInfo[] getInterestedEvents() {
        return [
            typeid(UserCreatedEvent)
        ];
    }

    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) {
        writeln("Listener2 received event: ", event);

        auto eventList = new EventList();

        if (eventType == typeid(UserCreatedEvent)) {
            auto meta = event.getMetadata();
            UserCreatedMeta userCreatedMeta = *meta.peek!(UserCreatedMeta);
            writeln(userCreatedMeta);
        } 

        return eventList;
    }
}
```

Note that whilst you are handling events, you can also create new events and pass those back to the dispatcher.
In this way, you can have events that create events that create events and so on.  There is no limit to the depth
of event creation.  See source/demo.d for an example of a handler that creates new events.

In order for listeners to do their thing, they must first be "attached" to an event dispatcher, e.g.

```
// Setup event dispatcher and attach listeners
auto dispatcher = new EventDispatcher();
dispatcher.attachListener(new Listener1());
dispatcher.attachListener(new Listener2());
```


## Adding events an event lists.

Once raised, events must be added an an event list.  E.g.

```
auto eventList = new EventList();
eventList.append(eventAppStarted, typeid(AppStartedEvent));
eventList.append(eventUserCreated, typeid(UserCreatedEvent));
```

Note that we pass in the event instance and also the type of the event.

## Dispatching the events.

In order for the event listeners to receive the events, we must dispatch via them using the eventList.  E.g.

```
eventList.dispatch(dispatcher);
```

For a full demonstration, see source/demo.d

If you have any feedback or suggestions, please let me know.
Thanks and enjoy :-)
