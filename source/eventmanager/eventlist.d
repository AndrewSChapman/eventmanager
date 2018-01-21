module eventmanager.eventlist;

import std.container : DList;
import std.algorithm.comparison : equal;

import std.stdio;

import eventmanager.abstractevent;
import eventmanager.eventinterface;
import eventmanager.eventdispatcher;

struct EventContainer
{
    TypeInfo eventType;
    EventInterface event;
}

interface EventListInterface {
    public void append(EventInterface event, TypeInfo eventType) @safe;
    public void dispatch(EventDispatcherInterface dispatcher) @safe;
    public DList!EventContainer getEventList() @safe;
    public ulong size() @safe;
}

class EventList : EventListInterface
{
    private DList!EventContainer eventList;

    this() @safe {
        this.eventList = DList!EventContainer();
    }  

    public void append(EventInterface event, TypeInfo eventType) @safe
    {
        EventContainer container;
        container.eventType = eventType;
        container.event = event;

        this.eventList.insertBack(container);
    }

    // Allow appending from one event list into another.
    public void append(EventListInterface newEventList) @safe {
        foreach (container; newEventList.getEventList()) {
            this.append(container.event, container.eventType);
        }
    }

    /**
    Process all of the events in this event list.  Each event may
    in turn create new events which must also be processed.  Keep
    looping until all events have been processed and no new events
    have been created.
    */
    public void dispatch(EventDispatcherInterface dispatcher) @safe
    {
        auto eventList = this.eventList;

        while (true) {
            auto newEventList = new EventList();

            foreach (container; eventList) {
                newEventList.append(dispatcher.dispatch(container.event, container.eventType));
            }

            // If no new events were created, terminate the loop.
            if (newEventList.size() == 0) {
                break;
            }

            // Use the "new event list" as the basis of the loop
            // for the next interation.
            eventList = newEventList.getEventList();
        }
    }

    public DList!EventContainer getEventList() @safe
    {
        return this.eventList;
    } 

    public ulong size() @safe
    {
        ulong count = 0;

        foreach (container; this.eventList) {
            ++count;
        }

        return count;
    }
}