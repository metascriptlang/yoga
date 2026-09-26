// Flexbox layout scenarios with hand-computed expected geometry.
// Native binary: exits non-zero on any mismatch, prints one PASS marker at
// the end (build via `msc build test/layout.test.ms` from the repo root).

import {
	yogaNode,
	yogaLeaf,
	freeYogaNode,
	layoutTree,
	calculateLayout,
	setStyle,
	YogaNode,
	layoutPass,
	freeLayoutTree,
	layoutGetChildren,
	layoutGetStyle,
	layoutGetLastStyle,
	layoutSetLastStyle,
	layoutGetYg,
	layoutSetYg,
	layoutSetFrame,
	FlexStyle,
	YGNode,
} from "../src/index";
import { exit } from "std/process";
import { yogaCountStart, yogaLiveNodes } from "./yogaCount.h";
@compile("./yogaCount.cpp", "-std=c++20");

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

function expectCount(label: string, actual: int32, expected: int32): void {
	checks += 1;
	if (actual !== expected) {
		failures += 1;
		console.log(
			"FAIL " + label + ": expected " + expected.toString() + " got " + actual.toString(),
		);
	}
}

function expectTrue(label: string, ok: boolean): void {
	checks += 1;
	if (!ok) {
		failures += 1;
		console.log("FAIL " + label);
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

function rowRightToLeft(): void {
	const root = yogaNode({ flexDirection: "row", width: 300.0, height: 100.0 }, [
		yogaLeaf({ width: 50.0 }),
		yogaLeaf({ width: 30.0 }),
	]);
	calculateLayout(root, 300.0, 100.0, "rtl");
	expectEq("rtl a.left", root.children[0].layout.left, 250.0);
	expectEq("rtl b.left", root.children[1].layout.left, 220.0);
	freeYogaNode(root);
}

function reverseRowSpaceBetween(): void {
	const style: FlexStyle = {
		flexDirection: "row-reverse",
		justifyContent: "space-between",
		alignItems: "flex-end",
		width: 200.0,
		height: 100.0,
	};
	const root = yogaNode(style, [
		yogaLeaf({ width: 50.0, height: 30.0 }),
		yogaLeaf({ width: 50.0, height: 40.0 }),
	]);
	layoutTree(root, 200.0, 100.0);
	expectEq("reverse a.left", root.children[0].layout.left, 150.0);
	expectEq("reverse b.left", root.children[1].layout.left, 0.0);
	expectEq("reverse a.top", root.children[0].layout.top, 70.0);
	freeYogaNode(root);
}

function wrapSkipsDisplayNone(): void {
	const style: FlexStyle = {
		flexDirection: "row",
		flexWrap: "wrap",
		alignContent: "flex-start",
		width: 100.0,
		height: 100.0,
	};
	const root = yogaNode(style, [
		yogaLeaf({ width: 40.0, height: 20.0 }),
		yogaLeaf({ width: 40.0, height: 20.0, display: "none" }),
		yogaLeaf({ width: 40.0, height: 20.0 }),
		yogaLeaf({ width: 40.0, height: 20.0 }),
	]);
	layoutTree(root, 100.0, 100.0);
	expectEq("wrap c.left", root.children[2].layout.left, 40.0);
	expectEq("wrap d.left", root.children[3].layout.left, 0.0);
	expectEq("wrap d.top", root.children[3].layout.top, 20.0);
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

export interface HostBox {
	flex: FlexStyle | null;
	lastFlex: FlexStyle | null;
	yg: Ptr<YGNode> | null;
	children: HostBox[];
	x: float32;
	y: float32;
	w: float32;
	h: float32;
}

export function layoutGetChildren(this n: HostBox): HostBox[] { return n.children; }
export function layoutGetStyle(this n: HostBox): FlexStyle | null { return n.flex; }
export function layoutGetLastStyle(this n: HostBox): FlexStyle | null { return n.lastFlex; }
export function layoutSetLastStyle(this n: HostBox, s: FlexStyle | null): void { n.lastFlex = s; }
export function layoutGetYg(this n: HostBox): Ptr<YGNode> | null { return n.yg; }
export function layoutSetYg(this n: HostBox, yg: Ptr<YGNode> | null): void { n.yg = yg; }
export function layoutSetFrame(
	this n: HostBox,
	x: float32,
	y: float32,
	w: float32,
	h: float32,
): void {
	n.x = x;
	n.y = y;
	n.w = w;
	n.h = h;
}

function hostBox(flex: FlexStyle, children: HostBox[]): HostBox {
	return {
		flex: flex,
		lastFlex: null,
		yg: null,
		children: children,
		x: 0.0,
		y: 0.0,
		w: 0.0,
		h: 0.0,
	};
}

function genericLayoutPassOnHostTree(): void {
	const grow = hostBox({ flexGrow: 1.0 }, []);
	const fixed = hostBox({ height: 50.0 }, []);
	const root = hostBox({ flexDirection: "column", width: 400.0, height: 300.0 }, [grow, fixed]);
	layoutPass(root, 400.0, 300.0);
	expectEq("hostPass a.height", grow.h, 250.0);
	expectEq("hostPass b.top", fixed.y, 250.0);
	expectEq("hostPass root.width", root.w, 400.0);
	freeLayoutTree(root);
	expectTrue("hostPass freed", root.yg === null && grow.yg === null);
}

function nullStyleReleasesYogaNode(): void {
	const leaf = hostBox({ height: 20.0 }, []);
	const child = hostBox({ height: 50.0 }, [leaf]);
	const other = hostBox({ height: 30.0 }, []);
	const root = hostBox({ flexDirection: "column", width: 100.0, height: 200.0 }, [child, other]);
	const live = yogaLiveNodes();
	layoutPass(root, 100.0, 200.0);
	child.flex = null;
	layoutPass(root, 100.0, 200.0);
	expectTrue("detach frees child", child.yg === null && leaf.yg === null);
	expectEq("detach other.top", other.y, 0.0);
	freeLayoutTree(root);
	expectCount("detach live yoga nodes", yogaLiveNodes(), live);
}

function removedChildFreedByHost(): void {
	const late = hostBox({ height: 50.0 }, [hostBox({ height: 20.0 }, [])]);
	const early = hostBox({ height: 10.0 }, []);
	const other = hostBox({ height: 30.0 }, []);
	const column: FlexStyle = { flexDirection: "column", width: 100.0, height: 200.0 };
	const root = hostBox(column, [late, early, other]);
	const live = yogaLiveNodes();
	layoutPass(root, 100.0, 200.0);
	root.children = [early, other];
	layoutPass(root, 100.0, 200.0);
	freeLayoutTree(late);
	expectEq("removeAfterPass other.top", other.y, 10.0);
	root.children = [other];
	freeLayoutTree(early);
	layoutPass(root, 100.0, 200.0);
	expectEq("removeBeforePass other.top", other.y, 0.0);
	freeLayoutTree(root);
	expectCount("remove live yoga nodes", yogaLiveNodes(), live);
}

function restyledChildRejoinsLayout(): void {
	const child = hostBox({ height: 50.0 }, [hostBox({ height: 20.0 }, [])]);
	const other = hostBox({ height: 30.0 }, []);
	const root = hostBox({ flexDirection: "column", width: 100.0, height: 200.0 }, [child, other]);
	layoutPass(root, 100.0, 200.0);
	child.flex = null;
	layoutPass(root, 100.0, 200.0);
	child.flex = { height: 40.0 };
	layoutPass(root, 100.0, 200.0);
	expectEq("rejoin child.height", child.h, 40.0);
	expectEq("rejoin leaf.height", child.children[0].h, 20.0);
	expectEq("rejoin other.top", other.y, 40.0);
	freeLayoutTree(root);
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

function minMaxHeightStrings(): void {
	const root = yogaNode({ flexDirection: "column", width: 100.0, height: 200.0 }, [
		yogaLeaf({ flexGrow: 1.0, maxHeight: "30" }),
		yogaLeaf({ height: 10.0, minHeight: "25%" }),
	]);
	layoutTree(root, 100.0, 200.0);
	expectEq("maxHStr a.height", root.children[0].layout.height, 30.0);
	expectEq("minHPct b.height", root.children[1].layout.height, 50.0);
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
	yogaCountStart();
	columnFlexGrow();
	rowJustifyCenter();
	rowRightToLeft();
	reverseRowSpaceBetween();
	wrapSkipsDisplayNone();
	paddingAndMargin();
	absolutePosition();
	nestedRowInColumn();
	relayoutAfterSetStyle();
	genericLayoutPassOnYogaNode();
	genericLayoutPassOnHostTree();
	nullStyleReleasesYogaNode();
	restyledChildRejoinsLayout();
	removedChildFreedByHost();
	percentWidthHeight();
	autoMarginCenters();
	flexBasisPercent();
	minMaxPercentClamp();
	minMaxHeightStrings();
	numericStringIsPoints();
	percentEdges();
	relayoutToPercent();
	expectCount("live yoga nodes at exit", yogaLiveNodes(), 0);
	if (failures === 0) {
		console.log("yoga-layout PASS (" + checks.toString() + " checks)");
	} else {
		console.log("yoga-layout FAIL: " + failures.toString() + "/" + checks.toString());
		exit(1);
	}
}

main();
