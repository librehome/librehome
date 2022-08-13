// Warning: this the pseudocode! Do NOT attempt to run!
// The device is invalid (hard coded to 0).
// Using reactive API.
export function reactive() {
    let aDevice: LibertasDevice = 0
    const tag = {};
    const timeout = 1000;
    const fd = 0;
    // Reactive Programming
    // Create event callback handlers
    Libertas_SetOnDevice(aDevice, (tag, event)=>{
        // TODO: Handle device events
    }, tag);
    Libertas_TimerNew(timeout, (tag)=> {
        // TODO: Handle timer event
    });
    Libertas_SetOnNetHttpResponse(fd, (tag, fd, data)=> {
        // TODO: Handle HTTP(S) response
    }, tag);

    // Infinite loop to drive the event callbacks.
    // Will exit if Libertas_ExitThread() is called.
    Libertas_WaitReactive();
}
