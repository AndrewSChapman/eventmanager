module eventmanager.eventdispatcher;

import std.container : SList;
import std.algorithm.comparison : equal;
import std.stdio;

import eventmanager.eventlistenerinterface;
import eventmanager.eventinterface;
import eventmanager.eventlist;

interface EventDispatcherInterface
{
    public void attachListener(EventListenerInterface listener);
    public EventListInterface dispatch(EventInterface event, TypeInfo eventType);
}

class EventDispatcher : EventDispatcherInterface
{
    // To clarify, this is a hashmap where an object type maps
    // to a singly linked list of eventlistenerinterfaces.
    private SList!EventListenerInterface[TypeInfo] listenerMap;
    
    public void attachListener(EventListenerInterface listener)
    {
        auto listenerType = typeid(listener);
        auto interestedEvents = listener.getInterestedEvents();

        foreach (eventType; interestedEvents) {
            if (!(eventType in this.listenerMap)) {
                this.listenerMap[eventType] = SList!EventListenerInterface(listener);
            } else {
                this.listenerMap[eventType].insertFront(listener);
            }
        }
    }

    public EventListInterface dispatch(EventInterface event, TypeInfo eventType)
    {
        auto eventList = new EventList();
        
        if(this.noListenersInterestedInThisEvent(eventType)) {
            return eventList;
        }

        event.setEventReceived();

        auto interestedListeners = this.listenerMap[eventType];

        foreach (listener; interestedListeners) {
            eventList.append(listener.handleEvent(event, eventType));
        }

        event.setEventDispatched();

        return eventList;
    }    

    private bool noListenersInterestedInThisEvent(TypeInfo eventType) {
        return !(eventType in this.listenerMap);
    }
}
