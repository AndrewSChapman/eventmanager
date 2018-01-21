module eventmanager.eventinterface;

import std.variant;
import eventmanager.abstractevent;

interface EventInterface
{
    public EventLifecycle getLifecycle() @safe;
    public Variant getMetadata();
    public void setEventReceived() @safe;
    public void setEventDispatched() @safe;
}