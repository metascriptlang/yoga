import { yogaNode, yogaLeaf, layoutTree, freeYogaNode } from "../../src/index";
import { yogaProbeReportFrame } from "./nativeProbe.h";

const root = yogaNode({ flexDirection: "row", justifyContent: "center", alignItems: "center", width: 300.0, height: 100.0 }, [
	yogaLeaf({ width: 50.0, height: 40.0 }),
	yogaLeaf({ width: 50.0, height: 40.0 }),
]);
layoutTree(root, 300.0, 100.0);
const frame = root.children[1].layout;
yogaProbeReportFrame(frame.left, frame.top, frame.width, frame.height);
freeYogaNode(root);
