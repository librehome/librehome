// Testing Typescript collection classes.
export function TestWeakSet() {
    const objweakSet = new WeakSet([{ text: "hi" }]);
    const obj1 = { text: "hello" };
    const obj2 = { text: "bye" };
    objweakSet.add(obj1);
    console.log(objweakSet.has(obj1));
    console.log(objweakSet.has(obj2));
    objweakSet.add(obj2);
    console.log(objweakSet.has(obj2));
}
