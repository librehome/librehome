// Test circular reference detection.
// If a tree structure is exposed as UI, it can not have
// non-nullable circular reference.
declare class NestA {
    a: number;
    b: NestB;
}

declare class NestB {
    b: number;
    a?: NestA;  // Important to be nullable!
}

export function TestCircularRef(sa: NestA) {
    console.log(sa);
}
