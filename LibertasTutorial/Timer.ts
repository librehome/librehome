// A simple timer that fires every 1 second (1000ms)
export function TestTimer() {
    const t = Libertas_TimerNew(1000, (tag, timer) => {
        console.log("TestTimer called.");
        Libertas_TimerUpdate(t, 1000); // Repeat itself
    }, undefined);
    Libertas_WaitReactive();
}