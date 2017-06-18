module eventmanager.eventlistenerinterface;

import eventmanager.eventinterface;
import eventmanager.eventlist;

interface EventListenerInterface
{
    public TypeInfo[] getInterestedEvents();
    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType);
}