// Libertas time series data API.
const DataQA_Schema: LibertasAvroSchema[] = [
    <LibertasAvroSchemaEnum>
    {
        "type": "enum",
        "name": "DayOfWeek",
        "symbols": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    },
    <LibertasAvroSchemaRecord>
    {
        "type": "record",
        "name": "TreeNode",
        "fields": [
            { "name": "value", "type": "string" },
            { "name": "children", "type": ["null", { "type": "array", "items": "TreeNode" }] }
        ]
    },
    <LibertasAvroSchemaRecord>
    {
        "type": "record",
        "name": "Tree",
        "fields": [
            { "name": "timestamp", "type": "double" },
            { "name": "index", "type": "long" },
            { "name": "dow", "type": "DayOfWeek" },
            { "name": "value", "type": "string" },
            { "name": "children", "type": ["null", { "type": "array", "items": "TreeNode" }] }
        ]
    },
];

enum DayOfWeek {
    Sun, Mon, Tue, Wed, Thu, Fri, Sat
}

interface Tree {
    timestamp: number;
    index: number;
    dow: string;
    value: string;
    children?: TreeNode[];
}

interface TreeNode {
    value: string;
    children?: TreeNode[];
}

export function DataQA(verify: boolean) {
    Libertas_DataInitSchema(DataQA_Schema);
    const db = Libertas_DataOpenTimeSeries("main", true)!;
    const [size, start] = Libertas_DataStatTimeSeries(db);
    if (verify) {
        let verified = true;
        for (let i = start; i < size; i++) {
            const record = Libertas_DataReadTimeSeries(db, i, i)[0];
            const value = record.v as Tree;
            if (record.i != value.index) {
                verified = false;
                break;
            }
        }
        console.log("Verification result", tostring(verified));
    } else {
        for (let i = 0; i < 100; i++) {
            const index = i + size;
            const treeVal: Tree = {
                timestamp: os.utcnow(),
                index: index,
                dow: DayOfWeek[index % 7],
                value: "Root",
                children: [
                    { value: "1-1", children: undefined },
                    {
                        value: "1-2", children: [
                            { value: "2-1", children: undefined },
                            { value: "2-2", children: undefined },
                            { value: "2-3", children: undefined },
                        ]
                    },
                    { value: "1-3", children: undefined },
                ]
            }
            // Index of Tree in schema is 2 (zero based)
            Libertas_DataWriteTimeSeries(db, treeVal, 2);
        }
    }
}
