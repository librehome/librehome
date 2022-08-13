// Thread API.
export function TestThread() {
    const threadFunc = function (a: number, b: number, c: number) {
        console.log("a=", a);
        Libertas_Wait(1000);
        console.log("b=", b);
        if (b == 9999) {
            Libertas_ExitThread();
        }
        Libertas_Wait(1000);
        console.log("c=", c);
    }

    // Create a thread
    const tid = Libertas_NewThread(threadFunc, 1, 2, 3);
    // Wait 1500 ms then terminate the thread
    Libertas_Wait(1500);
    // Terminate the thread
    Libertas_ExitThread(tid);

    Libertas_NewThread(threadFunc, 1, 9999, 3);
    // This thread will terminate naturally
}