// Flexbox layout scenarios with hand-computed expected geometry.
// Native binary: exits non-zero on any mismatch, prints one PASS marker at
// the end (build via `msc build test/layout.test.ms` from the repo root).

import { yogaNode, yogaLeaf, freeYogaNode, layoutTree, setStyle, YogaNode, layoutPass, layoutGetChildren, layoutGetStyle, layoutGetLastStyle, layoutSetLastStyle, layoutGetYg, layoutSetYg, layoutSetFrame } from "../src/index";
import { exit } from "std/process";

let checks: int32 = 0;
let failures: int32 = 0;

function expectEq(label: string, actual: float32, expected: float32): void {
	checks += 1;
	const d = actual - expected;
	const ok = d < 0.01 && d > -0.01;
	if (!ok) {
		failures += 1;
		console.log("FAIL " + label + ": expected " + expected.toString() + " got " + actual.toString());
	}
}

function columnFlexGrow(): void {
	const root = yogaNode({ flexDirection: "column", width: 400.0, height: 300.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		yogaLeaf({ height: 50.0 }),
	]);
	layoutTree(root, 400.0, 300.0);
	expectEq("colGrow a.height", root.children[0].layout.height, 250.0);
	expectEq("colGrow b.top", root.children[1].layout.top, 250.0);
	expectEq("colGrow b.height", root.children[1].layout.height, 50.0);
	freeYogaNode(root);
}

function rowJustifyCenter(): void {
	const root = yogaNode({ flexDirection: "row", justifyContent: "center", alignItems: "center", width: 300.0, height: 100.0 }, [
		yogaLeaf({ width: 50.0, height: 40.0 }),
		yogaLeaf({ width: 50.0, height: 40.0 }),
	]);
	layoutTree(root, 300.0, 100.0);
	expectEq("rowCenter a.left", root.children[0].layout.left, 100.0);
	expectEq("rowCenter b.left", root.children[1].layout.left, 150.0);
	expectEq("rowCenter a.top", root.children[0].layout.top, 30.0);
	freeYogaNode(root);
}

function paddingAndMargin(): void {
	const root = yogaNode({ flexDirection: "column", width: 200.0, height: 200.0, padding: 10.0 }, [
		yogaLeaf({ flexGrow: 1.0, margin: 5.0 }),
	]);
	layoutTree(root, 200.0, 200.0);
	expectEq("pad a.left", root.children[0].layout.left, 15.0);
	expectEq("pad a.top", root.children[0].layout.top, 15.0);
	expectEq("pad a.width", root.children[0].layout.width, 170.0);
	expectEq("pad a.height", root.children[0].layout.height, 170.0);
	freeYogaNode(root);
}

function absolutePosition(): void {
	const root = yogaNode({ width: 300.0, height: 300.0 }, [
		yogaLeaf({ position: "absolute", left: 20.0, top: 30.0, width: 50.0, height: 60.0 }),
	]);
	layoutTree(root, 300.0, 300.0);
	expectEq("abs a.left", root.children[0].layout.left, 20.0);
	expectEq("abs a.top", root.children[0].layout.top, 30.0);
	expectEq("abs a.width", root.children[0].layout.width, 50.0);
	expectEq("abs a.height", root.children[0].layout.height, 60.0);
	freeYogaNode(root);
}

function nestedRowInColumn(): void {
	const row = yogaNode({ flexDirection: "row", height: 60.0, gap: 10.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		yogaLeaf({ flexGrow: 1.0 }),
	]);
	const root = yogaNode({ flexDirection: "column", width: 210.0, height: 200.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		row,
	]);
	layoutTree(root, 210.0, 200.0);
	expectEq("nested row.top", row.layout.top, 140.0);
	expectEq("nested cell0.width", row.children[0].layout.width, 100.0);
	expectEq("nested cell1.left", row.children[1].layout.left, 110.0);
	freeYogaNode(root);
}

function relayoutAfterSetStyle(): void {
	const child = yogaLeaf({ height: 50.0 });
	const root = yogaNode({ flexDirection: "column", width: 100.0, height: 200.0 }, [child]);
	layoutTree(root, 100.0, 200.0);
	expectEq("relayout h0", child.layout.height, 50.0);
	setStyle(child, { height: 80.0 });
	layoutTree(root, 100.0, 200.0);
	expectEq("relayout h1", child.layout.height, 80.0);
	freeYogaNode(root);
}

// Generic layoutPass (sync.ms protocol) with YogaNode as consumer — same
// geometry as columnFlexGrow but driven through the cross-module generic.
function genericLayoutPassOnYogaNode(): void {
	const root = yogaNode({ flexDirection: "column", width: 400.0, height: 300.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		yogaLeaf({ height: 50.0 }),
	]);
	layoutPass(root, 400.0, 300.0);
	expectEq("genPass a.height", root.children[0].layout.height, 250.0);
	expectEq("genPass b.top", root.children[1].layout.top, 250.0);
	expectEq("genPass root.width", root.layout.width, 400.0);
	freeYogaNode(root);
}

function percentWidthHeight(): void {
	const root = yogaNode({ flexDirection: "column", width: 400.0, height: 300.0 }, [
		yogaLeaf({ width: "50%", height: "25%" }),
	]);
	layoutTree(root, 400.0, 300.0);
	expectEq("pct a.width", root.children[0].layout.width, 200.0);
	expectEq("pct a.height", root.children[0].layout.height, 75.0);
	freeYogaNode(root);
}

function autoMarginCenters(): void {
	const root = yogaNode({ flexDirection: "column", width: 300.0, height: 100.0 }, [
		yogaLeaf({ width: 100.0, height: 40.0, marginLeft: "auto", marginRight: "auto" }),
	]);
	layoutTree(root, 300.0, 100.0);
	expectEq("autoMargin a.left", root.children[0].layout.left, 100.0);
	freeYogaNode(root);
}

function flexBasisPercent(): void {
	const root = yogaNode({ flexDirection: "row", width: 200.0, height: 50.0 }, [
		yogaLeaf({ flexBasis: "25%" }),
		yogaLeaf({ flexGrow: 1.0 }),
	]);
	layoutTree(root, 200.0, 50.0);
	expectEq("basisPct a.width", root.children[0].layout.width, 50.0);
	expectEq("basisPct b.left", root.children[1].layout.left, 50.0);
	freeYogaNode(root);
}

function minMaxPercentClamp(): void {
	const root = yogaNode({ flexDirection: "row", width: 400.0, height: 50.0 }, [
		yogaLeaf({ flexGrow: 1.0, maxWidth: "25%" }),
		yogaLeaf({ width: 30.0, minWidth: "20%" }),
	]);
	layoutTree(root, 400.0, 50.0);
	expectEq("maxPct a.width", root.children[0].layout.width, 100.0);
	expectEq("minPct b.width", root.children[1].layout.width, 80.0);
	freeYogaNode(root);
}

function numericStringIsPoints(): void {
	const root = yogaNode({ flexDirection: "row", width: 300.0, height: 50.0 }, [
		yogaLeaf({ width: "120" }),
	]);
	layoutTree(root, 300.0, 50.0);
	expectEq("numStr a.width", root.children[0].layout.width, 120.0);
	freeYogaNode(root);
}

function percentEdges(): void {
	const root = yogaNode({ flexDirection: "column", width: 200.0, height: 100.0, padding: "10%" }, [
		yogaLeaf({ flexGrow: 1.0, marginLeft: "5%" }),
	]);
	layoutTree(root, 200.0, 100.0);
	// padding 10% of root width (200) = 20; margin % resolves against the
	// parent's CONTENT width (200 - 40 = 160), so 5% = 8 — yoga semantics.
	expectEq("pctPad a.left", root.children[0].layout.left, 28.0);
	expectEq("pctPad a.width", root.children[0].layout.width, 152.0);
	freeYogaNode(root);
}

function relayoutToPercent(): void {
	const child = yogaLeaf({ height: 50.0 });
	const root = yogaNode({ flexDirection: "column", width: 100.0, height: 200.0 }, [child]);
	layoutTree(root, 100.0, 200.0);
	expectEq("relayoutPct h0", child.layout.height, 50.0);
	setStyle(child, { height: "40%" });
	layoutTree(root, 100.0, 200.0);
	expectEq("relayoutPct h1", child.layout.height, 80.0);
	freeYogaNode(root);
}

function main(): void {
	columnFlexGrow();
	rowJustifyCenter();
	paddingAndMargin();
	absolutePosition();
	nestedRowInColumn();
	relayoutAfterSetStyle();
	genericLayoutPassOnYogaNode();
	percentWidthHeight();
	autoMarginCenters();
	flexBasisPercent();
	minMaxPercentClamp();
	numericStringIsPoints();
	percentEdges();
	relayoutToPercent();
	if (failures === 0) {
		console.log("yoga-layout PASS (" + checks.toString() + " checks)");
	} else {
		console.log("yoga-layout FAIL: " + failures.toString() + "/" + checks.toString());
		exit(1);
	}
}

main();
