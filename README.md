# EventManager

This library implements a variant of the pub/sub pattern, using events, an event list and event dispatchers.

## Events

Your app can raise events.  Events can store any metadata you like in structs.
An event must extend AbstractEvent and have a metadata struct type defined.

Here's an example of a metadata struct.  This struct can literally hold information you need.

```struct UserCreatedMeta
{
    uint userId;
    string firstName;
    string lastName;
}```

And here's an example of an event that contains that struct.

```class UserCreatedEvent : AbstractEvent!UserCreatedMeta
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
}```

Events will be processed or handled by "listeners".

## Event Listeners

Event Listeners declare what kind of events they are interested in and are then
responsible for handling each event type via the "handleEvent" method.

A listener can be any D class so long as it implements the EventListenerInterface.

Here's an example of an event listener.

```class Listener2 : EventListenerInterface
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
}```

Note that when handling events, you can create new events and pass those back to the dispatcher.
See source/demo.d for an example of a handler that creates new events.

To work, listeners must be "attached" to an event dispatcher, e.g.

// Setup event dispatcher and attach listeners
```auto dispatcher = new EventDispatcher();
dispatcher.attachListener(new Listener1());
dispatcher.attachListener(new Listener2());```


## Adding events an event lists.

Once raised, events must be added an an event list.  E.g.

```auto eventList = new EventList();
eventList.append(eventAppStarted, typeid(AppStartedEvent));
eventList.append(eventUserCreated, typeid(UserCreatedEvent));```

Note that we pass in the event instance and also the type of the event.

## Dispatching the events.

In order for the event listeners to receive the events, we must dispatch them.  E.g.

```eventList.dispatch(dispatcher);```

For a full demonstration, see source/demo.d

If you have any feedback or suggestions, please let me know.
Thanks and enjoy :-)
