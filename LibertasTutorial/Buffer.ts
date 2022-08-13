// Test lbuffer class API
export function TestBuffer() {
    const b = new lbuffer(100);
    console.log("b:len()", b.length);
    b[0] = 1;
    console.log("b[0]=", b[0]);
    b[0] = 2;
    console.log("b[0]=", b[0]);
    b[0] = 255;
    console.log("b[0]=", b[0]);
    b.set(1, "ABC");
    console.log("b=", b[0], b[1], b[2], b[3]);
    b.set(100, "ABC");
    console.log("b:len()", b.length);
    console.log("b=", b[100], b[101], b[1022], b[103]);

    let c = new lbuffer('ABCDEFGHIJKLMN');
    console.log(c.tostring(0, 2));
    console.log(c.tostring(1, 2));
    console.log(c.tostring(2, 2));
    c.set(2, "0123456789", 1, 5);
    console.log(c.tostring());

    c = new lbuffer('ABCDEFGHIJKLMN');
    c.clear(1, 5);
    console.log(c.tostring());

    c = new lbuffer('ABCDEFGHIJKLMN');
    c.remove(1, 5);
    console.log(c.tostring());
}
