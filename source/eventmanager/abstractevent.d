module eventmanager.abstractevent;

import std.datetime;
import std.variant;
import std.exception;
import std.stdio;

import eventmanager.eventinterface;

struct EventLifecycle
{
    long eventCreated;
    long eventReceived;
    long eventDispatched;
    long eventProcessingTime;   // How long the event took to be fully processed.
}

abstract class AbstractEvent(T) : EventInterface
{
    protected EventLifecycle lifecycle;
    protected T metadata;

    this(T metadata) @safe {
        //this.timestamp = Clock.currTime().toUnixTime();
        this.lifecycle.eventCreated = Clock.currStdTime();
        this.metadata = metadata;
    }

    public EventLifecycle getLifecycle() @safe
    {
        return this.lifecycle;
    }

    public Variant getMetadata()
    {
        return cast(Variant)this.metadata;
    }

    public void setEventReceived() @safe
    {
        this.lifecycle.eventReceived = Clock.currStdTime();
    }

    public void setEventDispatched() @safe in {
        enforce(this.lifecycle.eventReceived > 0, "Event must be flagged as being received BEFORE being dispatched");
    } body {
        this.lifecycle.eventDispatched = Clock.currStdTime();
        this.lifecycle.eventProcessingTime = this.lifecycle.eventDispatched - this.lifecycle.eventCreated;
    }
}

unittest {
    struct EventTestMetadata
    {
        int id;
        string name;
    }
        
    class TestEvent : AbstractEvent!EventTestMetadata
    {
        this(EventTestMetadata metadata)
        {
            super(metadata);
        }
    }

    EventTestMetadata metadata;
    metadata.id = 1;
    metadata.name = "Jane Doe";
    
    // Test instantiating an event
    auto testEvent = new TestEvent(metadata);

    // Ensure the lifecycle created time has been set
    auto lifeCycle = testEvent.getLifecycle();
    assert(lifeCycle.eventCreated > 0);

    // Ensure we can get the event metadata back correctly
    auto meta = testEvent.getMetadata();
    assert(meta.type == typeid(EventTestMetadata));
    EventTestMetadata metaEventTest = *meta.peek!(EventTestMetadata);
    assert(metaEventTest.id == 1);
    assert(metaEventTest.name == "Jane Doe");
}