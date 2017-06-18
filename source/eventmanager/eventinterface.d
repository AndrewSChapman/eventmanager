module eventmanager.eventinterface;

import std.variant;
import eventmanager.abstractevent;

interface EventInterface
{
    public EventLifecycle getLifecycle();
    public Variant getMetadata();
    public void setEventReceived();
    public void setEventDispatched();
}