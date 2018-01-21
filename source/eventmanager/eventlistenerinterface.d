module eventmanager.eventlistenerinterface;

import eventmanager.eventinterface;
import eventmanager.eventlist;

interface EventListenerInterface
{
    public TypeInfo[] getInterestedEvents() @safe;
    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) @safe;
}